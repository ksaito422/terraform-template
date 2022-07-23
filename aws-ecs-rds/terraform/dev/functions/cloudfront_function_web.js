function handler(event) {
  var request = event.request;
  var uri = request.uri;
  var headers = request.headers;

  var authString = 'Basic c2FpdG86QTE3MjJhYmM=';

  // Basic認証
  if (typeof headers.authorization === 'undefined' || headers.authorization.value !== authString) {
    return {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: { 'www-authenticate': { value: 'Basic' } },
    };
  }

  // URLの置換 例）/xxx -> /xxx/index.html
  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  } else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }

  return request;
}
