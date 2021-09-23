'use strict';


const requestHandlers = require('./handlers')


exports.handler = (event, context, callback) => {
    try {
        const { request } = event.Records[0].cf;

        for(const requestHandler of requestHandlers) {
            const result = requestHandler(request)

            if( !!result ) {
                console.error('==============================')
                console.error('RESULT')
                console.log(result)
                console.error('==============================')
                return callback(null, result)
            }
        }

        return callback(null, request)
    } catch(error) {
        console.error('==============================')
        console.error('ERROR')
        console.error(error)
        console.error('==============================')
    }
};