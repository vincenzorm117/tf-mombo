const { URL } = require('url')

/**
 *
 * @param {} request Amazon Request Object
 * @returns {String} Request URI with querystring appended in proper format.
 */
exports.hBuildURIFromRequest = (request) => {
    if (request.querystring === '') {
        return request.uri;
    }
    if (request.querystring.startsWith('?')) {
        return request.uri + request.querystring;
    }
    return request.uri + '?' + request.querystring;
}


exports.hCombineLocationAndParams = (location, querystring) => {
    if( !querystring ) {
        return location
    }
    // Replace query params with the ones passed in
    const url = new URL(location, 'https://domain.com')
    url.search = querystring.replace(/^\?/, '')
    // Return pathname with everything except the hostname
    return url.toString().replace(/https:\/\/domain.com/, '')
}