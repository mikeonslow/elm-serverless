require("dotenv").config();
var request = require("request");
var querystring = require("querystring");

exports.handler = (event, context, callback) => {
  const apiHost = process.env.API_HOST;
  const { body } = event;
  const filters = JSON.parse(body);
  const url = getUrl(apiHost, filters);

  request.get(url, function(err, httpResponse, responseBody) {
    callback(null, {
      statusCode: 200,
      body: responseBody
    });
  });
};

function getUrl(apiHost, filters) {
  return apiHost + "?" + querystring.stringify(filters);
}
