const amplifyConfig = '''{
  "auth": {
    "user_pool_id": "ap-northeast-1_nnn9GnI6p",
    "aws_region": "ap-northeast-1",
    "user_pool_client_id": "416iqnic0g90oumrt62j4rav1t",
    "identity_pool_id": "ap-northeast-1:837a213a-f641-4b31-a2c4-ba9eb1e8e0f1",
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
    "unauthenticated_identities_enabled": true
  },
  "version": "1"
}''';