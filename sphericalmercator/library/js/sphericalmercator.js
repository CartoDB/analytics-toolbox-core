/* eslint-disable no-unused-vars */
const SphericalMercator = (function() {
/* eslint-enable no-unused-vars */
// Closures including constants and other precalculated values.
    const cache = {};
    /* eslint-disable no-unused-vars */
    const EPSLN = 1.0e-10;
    /* eslint-enable no-unused-vars */
    const D2R = Math.PI / 180;
    const R2D = 180 / Math.PI;
    // 900913 properties.
    const A = 6378137.0;
    const MAXEXTENT = 20037508.342789244;

    function isFloat(n) {
        return Number(n) === n && n % 1 !== 0;
    }

    // SphericalMercator constructor: precaches calculations
    // for fast tile lookups.
    function SphericalMercator(options) {
        options = options || {};
        this.size = options.size || 256;
        if (!cache[this.size]) {
            let size = this.size;
            const c = cache[this.size] = {};
            c.Bc = [];
            c.Cc = [];
            c.zc = [];
            c.Ac = [];
            for (let d = 0; d < 30; d++) {
                c.Bc.push(size / 360);
                c.Cc.push(size / (2 * Math.PI));
                c.zc.push(size / 2);
                c.Ac.push(size);
                size *= 2;
            }
        }
        this.Bc = cache[this.size].Bc;
        this.Cc = cache[this.size].Cc;
        this.zc = cache[this.size].zc;
        this.Ac = cache[this.size].Ac;
    };

    // Convert lon lat to screen pixel value
    //
    // - `ll` {Array} `[lon, lat]` array of geographic coordinates.
    // - `zoom` {Number} zoom level.
    SphericalMercator.prototype.px = function(ll, zoom) {
        if (isFloat(zoom)) {
            const size = this.size * Math.pow(2, zoom);
            const d = size / 2;
            const bc = (size / 360);
            const cc = (size / (2 * Math.PI));
            const ac = size;
            const f = Math.min(Math.max(Math.sin(D2R * ll[1]), -0.9999), 0.9999);
            let x = d + ll[0] * bc;
            let y = d + 0.5 * Math.log((1 + f) / (1 - f)) * -cc;
            (x > ac) && (x = ac);
            (y > ac) && (y = ac);
            // (x < 0) && (x = 0);
            // (y < 0) && (y = 0);
            return [x, y];
        } else {
            const d = this.zc[zoom];
            const f = Math.min(Math.max(Math.sin(D2R * ll[1]), -0.9999), 0.9999);
            let x = Math.round(d + ll[0] * this.Bc[zoom]);
            let y = Math.round(d + 0.5 * Math.log((1 + f) / (1 - f)) * (-this.Cc[zoom]));
            (x > this.Ac[zoom]) && (x = this.Ac[zoom]);
            (y > this.Ac[zoom]) && (y = this.Ac[zoom]);
            // (x < 0) && (x = 0);
            // (y < 0) && (y = 0);
            return [x, y];
        }
    };

    // Convert screen pixel value to lon lat
    //
    // - `px` {Array} `[x, y]` array of geographic coordinates.
    // - `zoom` {Number} zoom level.
    SphericalMercator.prototype.ll = function(px, zoom) {
        if (isFloat(zoom)) {
            const size = this.size * Math.pow(2, zoom);
            const bc = (size / 360);
            const cc = (size / (2 * Math.PI));
            const zc = size / 2;
            const g = (px[1] - zc) / -cc;
            const lon = (px[0] - zc) / bc;
            const lat = R2D * (2 * Math.atan(Math.exp(g)) - 0.5 * Math.PI);
            return [lon, lat];
        } else {
            const g = (px[1] - this.zc[zoom]) / (-this.Cc[zoom]);
            const lon = (px[0] - this.zc[zoom]) / this.Bc[zoom];
            const lat = R2D * (2 * Math.atan(Math.exp(g)) - 0.5 * Math.PI);
            return [lon, lat];
        }
    };

    // Convert tile xyz value to bbox of the form `[w, s, e, n]`
    //
    // - `x` {Number} x (longitude) number.
    // - `y` {Number} y (latitude) number.
    // - `zoom` {Number} zoom.
    // - `tmsStyle` {Boolean} whether to compute using tms-style.
    // - `srs` {String} projection for resulting bbox (WGS84|900913).
    // - `return` {Array} bbox array of values in form `[w, s, e, n]`.
    SphericalMercator.prototype.bbox = function(x, y, zoom, tmsStyle, srs) {
    // Convert xyz into bbox with srs WGS84
        if (tmsStyle) {
            y = (Math.pow(2, zoom) - 1) - y;
        }
        // Use +y to make sure it's a number to avoid inadvertent concatenation.
        const ll = [x * this.size, (+y + 1) * this.size]; // lower left
        // Use +x to make sure it's a number to avoid inadvertent concatenation.
        const ur = [(+x + 1) * this.size, y * this.size]; // upper right
        const bbox = this.ll(ll, zoom).concat(this.ll(ur, zoom));

        // If web mercator requested reproject to 900913.
        if (srs === '900913') {
            return this.convert(bbox, '900913');
        } else {
            return bbox;
        }
    };

    // Convert bbox to xyx bounds
    //
    // - `bbox` {Number} bbox in the form `[w, s, e, n]`.
    // - `zoom` {Number} zoom.
    // - `tmsStyle` {Boolean} whether to compute using tms-style.
    // - `srs` {String} projection of input bbox (WGS84|900913).
    // - `@return` {Object} XYZ bounds containing minX, maxX, minY, maxY properties.
    SphericalMercator.prototype.xyz = function(bbox, zoom, tmsStyle, srs) {
    // If web mercator provided reproject to WGS84.
        if (srs === '900913') {
            bbox = this.convert(bbox, 'WGS84');
        }

        const ll = [bbox[0], bbox[1]]; // lower left
        const ur = [bbox[2], bbox[3]]; // upper right
        const pxLl = this.px(ll, zoom);
        const pxUr = this.px(ur, zoom);
        // Y = 0 for XYZ is the top hence minY uses pxUr[1].
        const x = [Math.floor(pxLl[0] / this.size), Math.floor((pxUr[0] - 1) / this.size)];
        const y = [Math.floor(pxUr[1] / this.size), Math.floor((pxLl[1] - 1) / this.size)];
        const bounds = {
            minX: Math.min.apply(Math, x) < 0 ? 0 : Math.min.apply(Math, x),
            minY: Math.min.apply(Math, y) < 0 ? 0 : Math.min.apply(Math, y),
            maxX: Math.max.apply(Math, x),
            maxY: Math.max.apply(Math, y)
        };
        if (tmsStyle) {
            const tms = {
                minY: (Math.pow(2, zoom) - 1) - bounds.maxY,
                maxY: (Math.pow(2, zoom) - 1) - bounds.minY
            };
            bounds.minY = tms.minY;
            bounds.maxY = tms.maxY;
        }
        return bounds;
    };

    // Convert projection of given bbox.
    //
    // - `bbox` {Number} bbox in the form `[w, s, e, n]`.
    // - `to` {String} projection of output bbox (WGS84|900913). Input bbox
    //   assumed to be the "other" projection.
    // - `@return` {Object} bbox with reprojected coordinates.
    SphericalMercator.prototype.convert = function(bbox, to) {
        if (to === '900913') {
            return this.forward(bbox.slice(0, 2)).concat(this.forward(bbox.slice(2, 4)));
        } else {
            return this.inverse(bbox.slice(0, 2)).concat(this.inverse(bbox.slice(2, 4)));
        }
    };

    // Convert lon/lat values to 900913 x/y.
    SphericalMercator.prototype.forward = function(ll) {
        const xy = [
            A * ll[0] * D2R,
            A * Math.log(Math.tan((Math.PI * 0.25) + (0.5 * ll[1] * D2R)))
        ];
        // if xy value is beyond maxextent (e.g. poles), return maxextent.
        (xy[0] > MAXEXTENT) && (xy[0] = MAXEXTENT);
        (xy[0] < -MAXEXTENT) && (xy[0] = -MAXEXTENT);
        (xy[1] > MAXEXTENT) && (xy[1] = MAXEXTENT);
        (xy[1] < -MAXEXTENT) && (xy[1] = -MAXEXTENT);
        return xy;
    };

    // Convert 900913 x/y values to lon/lat.
    SphericalMercator.prototype.inverse = function(xy) {
        return [
            (xy[0] * R2D / A),
            ((Math.PI * 0.5) - 2.0 * Math.atan(Math.exp(-xy[1] / A))) * R2D
        ];
    };

    return SphericalMercator;
})();
