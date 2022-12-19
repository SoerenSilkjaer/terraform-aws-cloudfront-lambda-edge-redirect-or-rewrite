'use strict';

const config = require('./config.json')

exports.handler = (event, context, callback) => {
  // Extract the request from the CloudFront event that is sent to Lambda@Edge
  const request = event.Records[0].cf.request;

  if (config.action === "permanent-redirect") {
    const path = config.destination_path == '' || !config.destination_path.startsWith('/') ? request.uri : config.destination_path;
    const response = {
      status: '301',
      statusDescription: `Redirecting`,
      headers: {
        location: [{
          key: 'Location',
          value: `https://${config.destination_domain}${path}`
        }]
      }
    };
    callback(null, response);
  }

  if (config.action === "temporary-redirect") {
    const path = config.destination_path == '' || !config.destination_path.startsWith('/') ? request.uri : config.destination_path;
    const response = {
      status: '307',
      statusDescription: `Redirecting`,
      headers: {
        location: [{
          key: 'Location',
          value: `https://${config.destination_domain}${path}`
        }]
      }
    };
    callback(null, response);
  }

  if (config.action === "rewrite") {

    /* Set custom origin fields*/
    request.origin = {
      custom: {
        domainName: config.destination_domain,
        port: 443,
        protocol: 'https',
        path: '',
        sslProtocols: ['TLSv1', 'TLSv1.1', 'TLSv1.2'],
        readTimeout: 60,
        keepaliveTimeout: 5,
        customHeaders: {}
      }
    };

    request.headers['host'] = [{ key: 'host', value: config.destination_domain}];
    callback(null, request)
  }
};
