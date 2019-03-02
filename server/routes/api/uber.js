const router = require('express').Router();
var Uber = require('node-uber');
require('dotenv').config()

var uber = new Uber({
  client_id: process.env.CLIENT_ID,
  client_secret: process.env.CLIENT_SECRET,
  server_token: process.env.SERVER_TOKEN,
  redirect_uri: 'https://localhost:8000/callback',
  name: 'FUND_MY_CAUSE'
//   language: 'en_US', // optional, defaults to en_US
//   sandbox: true, // optional, defaults to false
//   proxy: 'PROXY URL' // optional, defaults to none
});

router.get('/', (req, res, next) => {
    // Kick off the authentication process
    var scope = ['request', 'history', 'profile', 'places'];
    redirect_uri = uber.getAuthorizeUrl(scope, 'http://localhost:8000/api/uber/callback');
    console.log(redirect_uri)
    res.redirect(redirect_uri);
});

router.get('/callback', function(request, response) {
    console.log('inside callback')
    uber.authorizationAsync({authorization_code: request.query.code})
    .spread(function(access_token, refresh_token, authorizedScopes, tokenExpiration) {
      // store the user id and associated access_token, refresh_token, scopes and token expiration date
      console.log('New access_token retrieved: ' + access_token);
      console.log('... token allows access to scopes: ' + authorizedScopes);
      console.log('... token is valid until: ' + tokenExpiration);
      console.log('... after token expiration, re-authorize using refresh_token: ' + refresh_token);

      // redirect the user back to your actual app
    //   response.redirect('/web/index.html');
    })
    .error(function(err) {
      console.error(err);
    });
});

// router.get('/callback', (req, res) => {
//     uber.authorization({grantType: 'authorization_code', authorization_code: req.query.code}, function (err, access_token) {
//         uber.access_token = access_token;
//         console.log('Got an access token! Head to /book to initiate an ride request.');
//         res.send('Got an access token! Head to /book to initiate an ride request.');
//     });

// });

module.exports = router;