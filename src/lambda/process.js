require("dotenv").config();
var request = require("request");
var querystring = require("querystring");

exports.handler = async (event, context) => {
  const apiHost = process.env.API_HOST;
  const { body } = event;
  const filters = JSON.parse(body);
  const url = getUrl(apiHost, filters);

  request.get(url, function(err, httpResponse, responseBody) {
    console.log(err, httpResponse, responseBody);
    callback(null, {
      statusCode: 200,
      body: JSON.stringify(responseBody)
    });
  });
};

function getUrl(apiHost, filters) {
  return apiHost + "?" + querystring.stringify(filters);
}
