const amplifyconfig = '''{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "1.0",
        "identityManager": {
          "Default": {}
        },
        "credentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "ap-northeast-3:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
              "Region": "ap-northeast-3"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-northeast-3_zoQx6QlCC",
            "AppClientId": "37esecn7b2n0n1rs813rufis54",
            "AppClientSecret": "your-app-client-secret",
            "Region": "ap-northeast-3"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "https://aitakufrontend82775f8a-82775f8a-dev.auth.ap-northeast-3.amazoncognito.com",
              "AppClientId": "29d9jelb17ur25jnf49c4kb2jp",
              "SignInRedirectURI": "myapp://signin/",
              "SignOutRedirectURI": "myapp://signout/"
            }
          }
        }
      }
    }
  }
}''';
