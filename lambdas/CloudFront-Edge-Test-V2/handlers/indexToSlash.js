



module.exports = (request) => {

    const regexIndexToSlash = /\/index.html$/i

    if (regexIndexToSlash.test(request.uri)) {
        return {
            status: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                location: [{
                    key: 'location',
                    value: request.uri.replace(regexIndexToSlash, '/'),
                }],
            }
        }
    }
}