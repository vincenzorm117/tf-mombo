



module.exports= (request) => {
    if(request.method === 'OPTIONS') {
        return {
            status: 404,
            statusDescription: 'Not Found',
            headers: []
        }
    }
}