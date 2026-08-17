# hl-component-secret-manager

A CfHighlander component that creates AWS Secrets Manager secrets with randomly generated values based on configurable patterns.

## Overview

This component provisions one or more `AWS::SecretsManager::Secret` resources, each with a `GenerateSecretString` configuration that controls how the random secret value is generated. This is useful for seeding secrets (e.g., database passwords, API keys) at stack creation time without hardcoding sensitive values.

## Configuration

Secrets are defined as a hash under the `secrets` key in your configuration. Each entry in the hash becomes a separate `AWS::SecretsManager::Secret` resource.

### Configuration Options

Each secret supports the following properties:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `secret_name` | String | (none) | Optional. The name of the secret in AWS. Supports CloudFormation `Fn::Sub` variable interpolation. |
| `generate_string_key` | String | `password` | The key in the JSON structure where the generated password is stored. |
| `secret_string_template` | String | `{"username":"admin"}` | A JSON string template that defines the structure of the secret value. |
| `exclude_characters` | String | `"@/\` | Characters to exclude from the generated password. |
| `password_length` | Integer | `32` | The length of the generated password. |
| `exclude_lowercase` | Boolean | `false` | Exclude lowercase letters from the generated password. |
| `exclude_numbers` | Boolean | `false` | Exclude numbers from the generated password. |
| `exclude_punctuation` | Boolean | `false` | Exclude punctuation characters from the generated password. |
| `exclude_uppercase` | Boolean | `false` | Exclude uppercase letters from the generated password. |
| `include_space` | Boolean | `false` | Include space characters in the generated password. |
| `require_each_included_type` | Boolean | `true` | Require at least one character from each included character type. |

## Examples

### Single Secret (Default Config)

```yaml
secrets:
  default_secret:
    secret_name: "${EnvironmentName}/default-secret"
    generate_string_key: password
    secret_string_template: '{"username":"admin"}'
    exclude_characters: '"@/\'
    password_length: 32
    require_each_included_type: true
```

### Multiple Secrets

```yaml
secrets:
  app_credentials:
    secret_name: "${EnvironmentName}/app-credentials"
    generate_string_key: password
    secret_string_template: '{"username":"app_user"}'
    exclude_characters: '"@/\'
    password_length: 64
    require_each_included_type: true

  api_key:
    secret_name: "${EnvironmentName}/api-key"
    generate_string_key: api_key
    secret_string_template: '{"service":"myapi"}'
    password_length: 48
    exclude_punctuation: true

  db_password:
    generate_string_key: password
    secret_string_template: '{"username":"dbadmin"}'
    exclude_characters: '"@/\;+%'
    password_length: 16
    exclude_uppercase: true
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `EnvironmentName` | String | `dev` | The name of the environment (global parameter). |
| `EnvironmentType` | String | `development` | The type of environment. Allowed values: `development`, `production`. |

## Outputs

For each secret defined in the configuration, an output is created with:
- **Value**: The `Ref` of the secret (its ARN)
- **Export Name**: `${EnvironmentName}-secret-manager-<secret_key>`

## Testing

```bash
# Compile all test configurations
cfhighlander cftest --no-validate

# Run RSpec tests
rspec spec/
```
