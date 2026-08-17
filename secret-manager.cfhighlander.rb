CfhighlanderTemplate do

  Name 'secret-manager'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true, allowedValues: ['development', 'production']
  end

end
