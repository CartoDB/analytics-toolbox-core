const fs = require('fs');
const path = require('path');

module.exports = {
    checkDir: (pathlist) => {
        const dirpath = path.join(...pathlist);
        return fs.existsSync(dirpath);
    },
    createDir: (pathlist) => {
        const dirpath = path.join(...pathlist);
        if (!fs.existsSync(dirpath)) {
            fs.mkdirSync(dirpath);
        }
    },
    createFile: (pathlist, content) => {
        const filepath = path.join(...pathlist);
        fs.writeFileSync(filepath, content);
    },
    readFile: (pathlist) => {
        const filepath = path.join(...pathlist);
        return fs.readFileSync(filepath).toString();
    },
    currentDate: () => {
        return new Date().toISOString().slice(0, 10);
    },
    capitalize: (s) => {
        if (typeof s !== 'string') return '';
        return s.charAt(0).toUpperCase() + s.slice(1);
    },
    findPathInfo: () => {
        const cwd = process.cwd();
        const cwdStack = cwd.split(path.sep);
    
        const rootStack = findRoot(cwdStack) || cwdStack;
        const root = `${path.sep}${path.join(...rootStack)}`;

        const relative = path.relative(root, cwd);
        const relativeStack = relative.split(path.sep);

        const module = (relativeStack.length > 1) && relativeStack[1];
        const cloud = (relativeStack.length > 2) && relativeStack[2];
        const type = {
            'carto-spatial-extension': 'core', 
            'carto-advanced-spatial-extension': 'advanced'
        }[path.parse(root).name];

        return { root, module, cloud, type };
    }
};


function findRoot (stack) {
    if (stack.length > 0) {
        const next = stack.slice(0, stack.length-1);
        if (stack[stack.length-1] !== 'modules') {
            return findRoot(next);
        }
        return next;
    }
}