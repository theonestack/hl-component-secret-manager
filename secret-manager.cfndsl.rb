CloudFormation do

  tags = []
  extra_tags = external_parameters.fetch(:tags, {})
  tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{external_parameters[:component_name]}") }
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  tags.push(*extra_tags.map { |k, v| { Key: k, Value: FnSub(v) } }).uniq { |h| h[:Key] }

  secrets = external_parameters.fetch(:secrets, {})

  secrets.each do |secret_key, secret_config|
    # Convert secret_key to PascalCase for logical resource name
    logical_name = secret_key.split(/[_\-]/).map(&:capitalize).join('')

    generate_secret_string = {}

    if secret_config.key?('generate_string_key')
      generate_secret_string[:GenerateStringKey] = secret_config['generate_string_key']
    end

    if secret_config.key?('secret_string_template')
      generate_secret_string[:SecretStringTemplate] = secret_config['secret_string_template']
    end

    if secret_config.key?('exclude_characters')
      generate_secret_string[:ExcludeCharacters] = secret_config['exclude_characters']
    end

    if secret_config.key?('password_length')
      generate_secret_string[:PasswordLength] = secret_config['password_length']
    end

    if secret_config.key?('exclude_lowercase')
      generate_secret_string[:ExcludeLowercase] = secret_config['exclude_lowercase']
    end

    if secret_config.key?('exclude_numbers')
      generate_secret_string[:ExcludeNumbers] = secret_config['exclude_numbers']
    end

    if secret_config.key?('exclude_punctuation')
      generate_secret_string[:ExcludePunctuation] = secret_config['exclude_punctuation']
    end

    if secret_config.key?('exclude_uppercase')
      generate_secret_string[:ExcludeUppercase] = secret_config['exclude_uppercase']
    end

    if secret_config.key?('include_space')
      generate_secret_string[:IncludeSpace] = secret_config['include_space']
    end

    if secret_config.key?('require_each_included_type')
      generate_secret_string[:RequireEachIncludedType] = secret_config['require_each_included_type']
    end

    SecretsManager_Secret(logical_name) {
      if secret_config.key?('secret_name')
        Name FnSub(secret_config['secret_name'])
      end
      GenerateSecretString generate_secret_string
      Tags tags
    }

    Output(logical_name) {
      Value(Ref(logical_name))
      Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-#{secret_key}")
    }
  end

end
