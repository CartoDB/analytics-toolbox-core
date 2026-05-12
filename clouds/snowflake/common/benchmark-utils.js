// Per-function timing benchmarks for Snowflake modules. Sibling of test-utils.
//
// Mirrors clouds/oracle/common/benchmark_utils/__init__.py and
// clouds/bigquery/common/benchmark-utils.js so cross-cloud results stay
// comparable. Single timed execute+fetch run per case, no warmup-of-the-query,
// no medians — re-run a single file if a number looks off.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const snowflake = require('snowflake-sdk');

snowflake.configure({ insecureConnect: true });

const MISSING_CONFIG = '__missing_config__';
const _VERBOSE = Boolean(process.env.BENCHMARK_VERBOSE);

// One connection + auth handshake per process. Pre-warmed before every
// bench() timer starts so connection establishment isn't charged to the
// first query.
let _benchConn = null;
let _benchWarmedPromise = null;

function _connectionOptions () {
    const opts = {
        account: process.env.SF_ACCOUNT,
        username: process.env.SF_USER,
        database: process.env.SF_DATABASE,
        schema: (process.env.SF_PREFIX || '') + (process.env.SF_SCHEMA_DEFAULT || ''),
        role: process.env.SF_ROLE
    };
    if (process.env.SF_PASSWORD) {
        opts.password = process.env.SF_PASSWORD;
    } else if (process.env.SF_RSA_KEY) {
        const privateKeyObject = crypto.createPrivateKey({
            key: process.env.SF_RSA_KEY,
            format: 'pem',
            passphrase: process.env.SF_RSA_KEY_PASSWORD
        });
        opts.authenticator = 'SNOWFLAKE_JWT';
        opts.privateKey = privateKeyObject.export({ format: 'pem', type: 'pkcs8' });
    }
    return opts;
}

function _getBenchConn () {
    if (!_benchConn) {
        _benchConn = snowflake.createConnection(_connectionOptions());
        _benchWarmedPromise = new Promise((resolve) => {
            _benchConn.connect((err) => {
                if (err) {
                    // Resolve anyway so bench() can attribute the error properly.
                    return resolve();
                }
                _benchConn.execute({
                    sqlText: 'SELECT 1',
                    complete: () => resolve()
                });
            });
        });
    }
    return _benchConn;
}

async function _ensureWarmed () {
    _getBenchConn();
    await _benchWarmedPromise;
}

function _replacePlaceholders (sql) {
    return sql
        .replace(/@@SF_SCHEMA@@/g, process.env.SF_SCHEMA || '')
        .replace(/@@SF_ROLE@@/g, process.env.SF_ROLE || '');
}

function _executeAsync (sql) {
    return new Promise((resolve, reject) => {
        _benchConn.execute({
            sqlText: sql,
            complete: (err, _stmt, rows) => {
                if (err) return reject(err);
                resolve(rows);
            }
        });
    });
}

async function _runQueryTimed (sql) {
    return _executeAsync(_replacePlaceholders(sql));
}

async function _dropTable (fqTable) {
    // Best-effort cleanup; ignore failures (table may not exist).
    try {
        await _executeAsync(`DROP TABLE IF EXISTS ${_replacePlaceholders(fqTable)}`);
    } catch (_) { /* swallow */ }
}

// ---------- config loading ----------

let _configCache = null;

function _configDir () {
    // Set by each modules/Makefile; root's export wins over core's `?=`.
    const env = process.env.BENCHMARK_CONFIG_DIR;
    if (env) return path.resolve(env);
    // Fallback for direct `node <bench>` invocation (no Make involved).
    return path.resolve(__dirname, '..', 'modules', 'benchmark');
}

function _loadConfig () {
    if (_configCache !== null) return _configCache;
    const local = path.join(_configDir(), 'config.json');
    const template = path.join(_configDir(), 'config.template.json');
    let chosen;
    if (fs.existsSync(local)) {
        chosen = local;
    } else if (fs.existsSync(template)) {
        chosen = template;
        process.stderr.write(
            `[benchmark] Using ${template}; copy it to config.json to override.\n`
        );
    } else {
        _configCache = {};
        return _configCache;
    }
    try {
        _configCache = JSON.parse(fs.readFileSync(chosen, 'utf8'));
    } catch (e) {
        process.stderr.write(`[benchmark] Failed to parse ${chosen}: ${e.message}\n`);
        _configCache = {};
    }
    return _configCache;
}

function configFor (fnName) {
    const entry = _loadConfig()[fnName];
    if (!entry || (Array.isArray(entry) && entry.length === 0)) {
        return [{ [MISSING_CONFIG]: true }];
    }
    return Array.isArray(entry) ? entry : [entry];
}

// ---------- output ----------

let _resultsPathCache = null;
let _headerPrinted = false;

function _resultsPath () {
    if (_resultsPathCache) return _resultsPathCache;
    const env = process.env.BENCHMARK_RESULTS_FILE;
    if (env) {
        _resultsPathCache = env;
    } else {
        const ts = new Date().toISOString().replace(/[:.]/g, '-').replace(/-\d+Z$/, 'Z');
        _resultsPathCache = path.join(process.cwd(), 'dist', `benchmark_${ts}.md`);
    }
    fs.mkdirSync(path.dirname(_resultsPathCache), { recursive: true });
    return _resultsPathCache;
}

function _quiet () {
    return Boolean(process.env.BENCHMARK_HEADER_WRITTEN);
}

function _ensureHeader () {
    if (_headerPrinted || _quiet()) {
        _headerPrinted = true;
        return;
    }
    _headerPrinted = true;
    const keep = Boolean(process.env.BENCHMARK_KEEP_OUTPUT);
    const header = keep
        ? '\n| Function | Params | Time (s) | Error | Output Table |\n|---|---|---|---|---|\n'
        : '\n| Function | Params | Time (s) | Error |\n|---|---|---|---|\n';
    process.stdout.write(header);
    fs.appendFileSync(_resultsPath(), header);
}

function _formatParams (params, maxValueLen = 60) {
    if (!params || Object.keys(params).length === 0) return '-';
    const parts = [];
    for (const [k, v] of Object.entries(params)) {
        if (k === 'output_table') continue;
        let s = String(v);
        if (s.length > maxValueLen) s = s.slice(0, maxValueLen - 3) + '...';
        parts.push(`${k}=${s}`);
    }
    return parts.join(', ') || '-';
}

async function _dropBenchTable (fqn) {
    try {
        await _runQueryTimed(`DROP TABLE IF EXISTS ${fqn}`);
    } catch (_) { /* best-effort */ }
}

function _sanitizeError (e) {
    const msg = (e && e.message) ? e.message : String(e);
    if (_VERBOSE) return msg.replace(/\n+/g, ' ').replace(/\|/g, '\\|');
    return msg.split('\n', 1)[0].slice(0, 120).replace(/\|/g, '\\|');
}

function _substitute (template, params) {
    return template.replace(/\$\{(\w+)\}/g, (_, k) => {
        if (params && Object.prototype.hasOwnProperty.call(params, k)) return params[k];
        throw new Error(`benchmark: missing template param "${k}"`);
    });
}

// ---------- public API ----------

async function bench ({ function: fnName, sql, params, skip_reason: skipReason }) {
    _ensureHeader();

    const isMissing = Boolean(params && params[MISSING_CONFIG]);
    if (isMissing) {
        delete params[MISSING_CONFIG];
        skipReason = `no entry for ${fnName} in config.json`;
    }

    const paramsStr = _formatParams(params);
    let elapsed = 0;
    let status = 'pass';
    let timeStr = 'n/a';
    let errorStr = '-';

    if (skipReason) {
        errorStr = `skipped: ${skipReason}`;
        status = isMissing ? 'no_config' : 'skip';
    } else {
        const outputTable = (params && params.output_table) || null;
        try {
            const finalSql = _substitute(sql, params || {});
            await _ensureWarmed();
            if (outputTable) await _dropBenchTable(outputTable);
            const start = process.hrtime.bigint();
            await _runQueryTimed(finalSql);
            elapsed = Number(process.hrtime.bigint() - start) / 1e9;
            timeStr = elapsed.toFixed(2);
        } catch (e) {
            errorStr = _sanitizeError(e);
            status = 'fail';
        } finally {
            if (outputTable && !process.env.BENCHMARK_KEEP_OUTPUT) {
                await _dropBenchTable(outputTable);
            }
        }
    }

    const outputTableDisplay = ((params && params.output_table) || '-')
        .replace(/@@SF_SCHEMA@@/g, process.env.SF_SCHEMA || '');
    const outputTableCol = process.env.BENCHMARK_KEEP_OUTPUT
        ? ` ${outputTableDisplay} |`
        : '';
    const row = `| ${fnName} | ${paramsStr} | ${timeStr} | ${errorStr} |${outputTableCol}`;
    if (!_quiet()) process.stdout.write(row + '\n');
    fs.appendFileSync(_resultsPath(), row + '\n');

    return { status, elapsed };
}

async function benchmark ({ function: fnName, sql, cleanup }) {
    cleanup = cleanup || [];
    const keep = Boolean(process.env.BENCHMARK_KEEP_OUTPUT);
    const counts = { pass: 0, fail: 0, skip: 0, no_config: 0 };
    let totalTime = 0;

    try {
        for (const caseRaw of configFor(fnName)) {
            const isMissing = Boolean(caseRaw[MISSING_CONFIG]);
            const tables = isMissing ? [] : cleanup.map(t => _substitute(t, caseRaw));
            for (const tbl of tables) await _dropTable(tbl);
            try {
                const { status, elapsed } = await bench({
                    function: fnName,
                    sql,
                    params: caseRaw
                });
                totalTime += elapsed;
                counts[status] += 1;
            } finally {
                if (!keep) {
                    for (const tbl of tables) await _dropTable(tbl);
                }
            }
        }

        const total = counts.pass + counts.fail + counts.skip + counts.no_config;
        let line;
        if (counts.fail) {
            line = `✗ ${fnName} (${counts.fail}/${total} failed)`;
        } else if (counts.no_config === total) {
            line = `- ${fnName} (no config)`;
        } else if (counts.pass === 0) {
            const skipped = counts.skip + counts.no_config;
            line = `- ${fnName} (${skipped} skipped)`;
        } else {
            let suffix = `${totalTime.toFixed(2)}s`;
            const skipped = counts.skip + counts.no_config;
            if (skipped) suffix += `, ${skipped} skipped`;
            line = `✓ ${fnName} (${suffix})`;
        }
        process.stdout.write(line + '\n');
    } finally {
        // snowflake-sdk keeps the event loop alive; close the connection
        // explicitly so the file process exits cleanly after benchmark().
        if (_benchConn) {
            try {
                await new Promise((resolve) => _benchConn.destroy(() => resolve()));
            } catch (_) { /* swallow */ }
            _benchConn = null;
        }
    }
}

module.exports = { benchmark, bench, configFor };