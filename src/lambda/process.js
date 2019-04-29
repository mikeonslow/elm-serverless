require('dotenv').config();
var request = require('request');
var querystring = require('querystring');

exports.handler = (event, context, callback) => {

  const apiHost = process.env.API_HOST;
  const {body} = event;
  var filters = { 'by_state': 'michigan', 'by_city': 'ferndale' };

  const url = getUrl(apiHost, filters);
  
  request.get(url, function (err, httpResponse, body) {
    callback(null, {
      headers: [],
      statusCode: 200,
      body: body,
    }); 
  });
};

function getUrl(apiHost, filters)
{
  return apiHost + '?' + querystring.stringify(filters);
}