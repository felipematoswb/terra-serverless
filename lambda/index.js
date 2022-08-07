const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

const ownTable = 'pets'

exports.handler = async (event, context) => {
    let body;
    let statusCode = 200;
    const headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Headers" : "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS, PUT, GET, DELETE"
    };

    try {
        switch (event.httpMethod + ' ' + event.resource) {
            case "DELETE /pets/{id}":
                await dynamo.delete({TableName: ownTable, Key: {id: event.pathParameters.id}}).promise();
                    body = `Deleted item ${event.pathParameters.id}`;
                break;
            case "GET /pets/{id}":
                body = await dynamo.get({TableName: ownTable, Key: {id: event.pathParameters.id}}).promise();
            break;
            case "GET /pets":
                body = await dynamo.scan({ TableName: ownTable }).promise();
            break;
                case "PUT /pets":
                let requestJSON = JSON.parse(event.body);
                await dynamo.put({TableName: ownTable, Item: {id: requestJSON.id, race: requestJSON.race, age: requestJSON.age}}).promise();
                body = `Put pet id: ${requestJSON.id}, race: ${requestJSON.race}, age: ${requestJSON.age}`;
            break;
            default:
            throw new Error('Unsupported route: "${event.httpMethod + " " + event.resource}"');
        }
    } catch (err) {
        statusCode = 400;
        body = err.message;
    } finally {
        body = JSON.stringify(body);
    }

    return {
        statusCode,
        body,
        headers
    };
};