const amplifyConfig = '''{
  "auth": {
    "user_pool_id": "ap-northeast-1_WHZCKdK8W",
    "aws_region": "ap-northeast-1",
    "user_pool_client_id": "71d142rj4s24ldl7picrhpakm2",
    "identity_pool_id": "ap-northeast-1:d5e7137f-5831-402e-b091-24b22697d6c7",
    "mfa_methods": [],
    "standard_required_attributes": [
      "email"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "oauth": {
      "identity_providers": [
        "GOOGLE"
      ],
      "redirect_sign_in_uri": [
        "http://localhost:52905/",
        "https://tinplus.harvestful.tokyo/"
      ],
      "redirect_sign_out_uri": [
        "http://localhost:52905/",
        "https://tinplus.harvestful.tokyo/"
      ],
      "response_type": "code",
      "scopes": [
        "phone",
        "email",
        "openid",
        "profile",
        "aws.cognito.signin.user.admin"
      ],
      "domain": "0e9ae3a5647d64c6d914.auth.ap-northeast-1.amazoncognito.com"
    },
    "unauthenticated_identities_enabled": true
  },
  "version": "1"
}''';