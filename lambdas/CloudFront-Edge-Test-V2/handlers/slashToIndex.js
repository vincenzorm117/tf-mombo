



module.exports = (request) => {
    if( /\/$/.test(request.uri) ) {
        request.uri += 'index.html'
        return request;
    }
}