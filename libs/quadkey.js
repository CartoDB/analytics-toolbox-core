
/**
 * @typedef xycoord
 * @type {object}
 * @property {number} x x coordinate
 * @property {number} y y coordinate
 */

/**
 * @typedef geocoord
 * @type {object}
 * @property {number} lat latitude
 * @property {number} lng longitude
 */

/**
 * @typedef bbox
 * @type {object}
 * @property {geocoord} min minimum coordinates for the bounding box
 * @property {geocoord} max maximum coordinates for the bounding box
 */

var EarthRadius = 6378137.0
  , MinLatitude = -85.05112878
  , MaxLatitude = 85.05112878
  , MinLongitude = -180.0
  , MaxLongitude = 180.0;

var Direction = Object.freeze({
	Up : 0,
	Down : 1,
	Left : 2,
	Right : 3
});

String.prototype.replaceAt = function(index, character) {
    return this.substr(0, index) + character + this.substr(index + character.length);
}

function horizontal(direction) {
	return (direction == Direction.Left || direction == Direction.Right)
}

/**
 * clips a number by a minimum and maximum value
 * @param  {number} n        the number to clip
 * @param  {number} minValue minimum value, if n is less this will return
 * @param  {number} maxValue maximum value, if n is greater than this will return
 * @return {number}          value of n clipped to be >= minValue and <= maxValue
 */
function clip( n, minValue, maxValue ) {
	return Math.min(Math.max(n, minValue), maxValue);
}

/**
 * get the size of the map in pixels for a specified detail level
 * @param  {number} detail map detail level
 * @return {number}        size of the map in pixels for the given detail level
 */
function mapSize( detail ) {
	return 256 << parseInt(detail, 10);
}

/**
 * translates a character in a particular direction
 * @param  {character} keyChar   the character to translate
 * @param  {Direction} direction the direction to translate to
 * @return {character}           translated character
 */
function keyCharTranslate( keyChar, direction ) {
	switch(keyChar) {
		case '0':
			return horizontal(direction) ? '1' : '2';
		case '1':
			return horizontal(direction) ? '0' : '3';
		case '2':
			return horizontal(direction) ? '3' : '0';
		case '3':
			return horizontal(direction) ? '2' : '1';
		default:
			throw new Error('Invalid key character: ' + keyChar);
	}
}

/**
 * translates a quadkey string in a particular direction recursively
 * @param  {string} key          the key to translate
 * @param  {int} index           index to start translating from (first call should pass in last index)
 * @param  {Direction} direction the direction to translate the key
 * @return {string}              translated string
 */
function keyTranslate( key, index, direction ) {
	if(key === '') {
		return '';
	}

	var savedChar = key[index];
	key = key.replaceAt(index, keyCharTranslate(key[index], direction));
	
	if(index > 0) {
		if(((savedChar == '0') && (direction == Direction.Left  || direction == Direction.Up))   ||
           ((savedChar == '1') && (direction == Direction.Right || direction == Direction.Up))   ||
           ((savedChar == '2') && (direction == Direction.Left  || direction == Direction.Down)) ||
           ((savedChar == '3') && (direction == Direction.Right || direction == Direction.Down))) {
			key = keyTranslate(key, index - 1, direction);
		}
	}
	return key;
}

/**
 * returns the sibling of the given quadkey and will wrap 
 * @param  {string} quadkey      key to get sibling of
 * @param  {Direction} direction direction of sibling from key
 * @return {string}              sibling key
 */
sibling = function( quadkey, direction ) {
	direction = {
		'left' : Direction.Left,
		'right' : Direction.Right,
		'up' : Direction.Up,
		'down' : Direction.Down
	}[direction];

	return keyTranslate(quadkey, quadkey.length - 1, direction);
}

/**
 * convert a pixel coordinate to a location at a specific map detail
 * @param  {xycoord}  pixel  the pixel coordinate to convert
 * @param  {number}   detail detail level of map to use
 * @return {geocoord}        location value for the input pixel coordinate at the input detail level
 */
pixelToLocation = function( pixel, detail ) {
	var size = parseFloat(mapSize(detail))
	  , x = (clip(parseFloat(pixel.x), 0, size - 1.0) / size) - 0.5
	  , y = 0.5 - (clip(parseFloat(pixel.y), 0, size - 1.0) / size)
	  , lat = 90.0 - 360.0 * Math.atan(Math.exp(-1.0 * y * 2.0 * Math.PI)) / Math.PI
	  , lng = 360.0 * x;
	return {
		lat: lat,
		lng: lng
	};
};

/**
 * convert tile coordinates to pixel coordinates
 * @param  {xycoord} tile tile coordinates
 * @return {xycoord}      pixel coordinates
 */
tileToPixel = function( tile ) {
	return {
		x: (tile.x * 256),
		y: (tile.y * 256)
	};
};

/**
 * convert tile coordinates to quadkey at specific detail level
 * @param  {xycoord} tile   tile coordinates
 * @param  {number}  detail map detail level to use for conversion
 * @return {string}         quadkey for input tile coordinates at input detail level
 */
tileToQuadkey = function( tile, detail ) {
	var out = "";
	for( var i = detail; i > 0; i-- ) {
		var digit = '0'
		  , value = digit.charCodeAt(0)
		  , mask = BigInt(1) << (BigInt(i - 1));

		if((BigInt(tile.x) & mask) != 0) {
			value++;
		}
		if((BigInt(tile.y) & mask) != 0) {
			value++;
			value++;
		}

		out += String.fromCharCode(value);
	}
	return out;
};

/**
 * convert quadkey to tile coordinates, detail level can be inferred from the length of 
 * the quadkey string.
 * @param  {string}  quadkey quadkey to be converted
 * @return {xycoord}         tile coordinates
 */
quadkeyToTile = function( quadkey ) {
	var tileX = 0
	  , tileY = 0
	  , detail = quadkey.length;
	for( var i = detail; i > 0; i--) {
		var mask = 1 << (i - 1)
		  , index = detail - i;
		switch(quadkey[index]) {
			case '0':
				break;
			case '1':
				tileX |= mask;
				break;
			case '2':
				tileY |= mask;
				break;
			case '3':
				tileX |= mask;
				tileY |= mask;
				break;
			default:
				throw new Error("Invalid quadkey");
		}
	}
	return {
		x: tileX,
		y: tileY
	};
};

/**
 * convert tile coordinates to location at specific detail level, this will be the lat,lng of the tile corner
 * @param  {xycoord}  tile   tile coordinates
 * @param  {number}   detail map detail level used in the conversion
 * @return {geocoord}        location of tile at input detail level
 */
tileToLocation = function( tile, detail ) {
	var pixel = tileToPixel(tile);
	return pixelToLocation(pixel, detail);
};

/**
 * get tile coordinates for location at specific detail level
 * @param  {geocoord} location location coordinates to convert to tile
 * @param  {number}   detail   map detail level of tile to return
 * @return {xycoord}           tile coordinates
 */
locationToTile = function ( location, detail ) {
	const world_limit_half = EarthRadius * Math.PI;
	const world_range = world_limit_half * 2;
	const radians_over_degrees = Math.PI / 180.0;

	const x_transform = (x => world_limit_half + (x * world_range) / 360);
	const y_transform = (y => {
			y *= radians_over_degrees;
			y = Math.log(Math.tan(y) + (1.0 / Math.cos(y)));
			return world_limit_half - (y * EarthRadius);
		});

	const longitude = clip(location.lng, MinLongitude, MaxLongitude);
	const latitude = clip(location.lat, MinLatitude, MaxLatitude);

	const zoom_divisor = world_range / Math.pow(2, detail);
	const max_tile = Math.pow(2, detail) - 1;

	const x = Math.min(max_tile, Math.floor((x_transform(longitude)) / zoom_divisor));
	const y = Math.min(max_tile, Math.floor((y_transform(latitude)) / zoom_divisor));

    return {x, y};
};

/**
 * get quadkey for location at specific detail level
 * @param  {geocoord} location location coordinates to convert to quadkey
 * @param  {number}   detail   map detail level of quadkey to return
 * @return {string}            quadkey the input location resides in for the input detail level
 */
locationToQuadkey = function( location, detail ) {
	return tileToQuadkey(locationToTile(location, detail), detail);
};

/**
 * get the bounding box for a quadkey in location coordinates
 * @param  {string} quadkey quadkey to get bounding box of
 * @return {bbox}           bounding box for the input quadkey 
 */
bbox = function( quadkey ) {
	var tile = quadkeyToTile(quadkey)
	  , nextTile = { x: tile.x + 1, y: tile.y + 1 }
	  , detail = quadkey.length
	  , first = tileToLocation(tile, detail)
	  , second = tileToLocation(nextTile, detail)
	  , minCoord = { lat: Math.min(first.lat, second.lat), lng: Math.min(first.lng, second.lng) }
	  , maxCoord = { lat: Math.max(first.lat, second.lat), lng: Math.max(first.lng, second.lng) };

	return {
		min: minCoord,
		max: maxCoord
	};
};

/**
 * determine if a location is inside a quadkey
 * @param  {geocoord} location location to check if inside quadkey
 * @param  {string}   quadkey  quadkey to check if location is inside it
 * @return {boolean}           true if location is inside quadkey and false otherwise
 */
inside = function( location, quadkey ) {
	return (locationToQuadkey(location, quadkey.length) === quadkey);
};

/**
 * get the center origin location of a quadkey
 * @param  {string}   quadkey quadkey to get the center origin location of
 * @return {geocoord}         location coordinates of teh center origin of the input quadkey
 */
origin = function( quadkey ) {
	var bboxCoords = bbox(quadkey)
	  , centerLat = (bboxCoords.min.lat + bboxCoords.max.lat) / 2.0
	  , centerLng = (bboxCoords.min.lng + bboxCoords.max.lng) / 2.0;
	return {
		lat: centerLat,
		lng: centerLng
	};
};

/**
 * get all the children quadkeys of a quadkey
 * @param  {string} quadkey quadkey to get the children of
 * @return {array}          array of quadkeys representing the children of the input quadkey
 */
children = function( quadkey ) {
	return [quadkey + '0', quadkey + '1', quadkey + '2', quadkey + '3'];
};

/**
 * get the parent of a quadkey
 * @param  {string} quadkey quadkey to get the parent of
 * @return {string}         parent of the input quadkey
 */
parent = function( quadkey ) {
	return quadkey.substring(0, quadkey.length - 1);
};


