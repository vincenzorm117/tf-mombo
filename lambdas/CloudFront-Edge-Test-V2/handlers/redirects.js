const { hBuildURIFromRequest, hCombineLocationAndParams } = require('../helpers')
const { redirects } = require('../config.json');



module.exports = (request) => {

    for(const { matchPath, location } of redirects) {
        // Ensure matchPath, location are non empty strings
        if( typeof matchPath !== 'string' || matchPath.length <= 0 || typeof location !== 'string' || location.length <= 0 ) {
            continue
        }

        const regex = new RegExp(matchPath, 'i');
        const matchURI = hBuildURIFromRequest(request);


        if (regex.test(matchURI)) {
            return {
                status: 301,
                statusDescription: 'Moved Permanently',
                headers: {
                    location: [{
                        key: 'location',
                        value: hCombineLocationAndParams(location, request.querystring)
                    }]
                }
            }
        }

    }
}