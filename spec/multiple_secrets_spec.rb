require 'yaml'

describe 'compiled component secret-manager' do

  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest --no-validate --tests tests/multiple_secrets.test.yaml")).to be_truthy
    end
  end

  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/multiple_secrets/secret-manager.compiled.yaml") }

  context "Resource" do

    context "AppCredentials" do
      let(:resource) { template["Resources"]["AppCredentials"] }

      it "is of type AWS::SecretsManager::Secret" do
        expect(resource["Type"]).to eq("AWS::SecretsManager::Secret")
      end

      it "to have property GenerateSecretString" do
        expect(resource["Properties"]["GenerateSecretString"]).to include(
          "GenerateStringKey" => "password",
          "SecretStringTemplate" => '{"username":"app_user"}',
          "PasswordLength" => 64,
          "ExcludeCharacters" => "\"@/\\",
          "RequireEachIncludedType" => true
        )
      end

      it "to have property Name" do
        expect(resource["Properties"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}/app-credentials"})
      end

      it "to have property Tags" do
        expect(resource["Properties"]["Tags"]).to include(
          {"Key" => "Name", "Value" => {"Fn::Sub" => "${EnvironmentName}-secret-manager"}},
          {"Key" => "Environment", "Value" => {"Ref" => "EnvironmentName"}},
          {"Key" => "EnvironmentType", "Value" => {"Ref" => "EnvironmentType"}}
        )
      end
    end

    context "ApiKey" do
      let(:resource) { template["Resources"]["ApiKey"] }

      it "is of type AWS::SecretsManager::Secret" do
        expect(resource["Type"]).to eq("AWS::SecretsManager::Secret")
      end

      it "to have property GenerateSecretString" do
        expect(resource["Properties"]["GenerateSecretString"]).to include(
          "GenerateStringKey" => "api_key",
          "SecretStringTemplate" => '{"service":"myapi"}',
          "PasswordLength" => 48,
          "ExcludePunctuation" => true,
          "RequireEachIncludedType" => false
        )
      end

      it "to have property Name" do
        expect(resource["Properties"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}/api-key"})
      end
    end

    context "DbPassword" do
      let(:resource) { template["Resources"]["DbPassword"] }

      it "is of type AWS::SecretsManager::Secret" do
        expect(resource["Type"]).to eq("AWS::SecretsManager::Secret")
      end

      it "to have property GenerateSecretString" do
        expect(resource["Properties"]["GenerateSecretString"]).to include(
          "GenerateStringKey" => "password",
          "SecretStringTemplate" => '{"username":"dbadmin"}',
          "PasswordLength" => 16,
          "ExcludeUppercase" => true,
          "RequireEachIncludedType" => true
        )
      end

      it "should not have a Name property" do
        expect(resource["Properties"]["Name"]).to be_nil
      end
    end

  end

  context "Outputs" do

    context "AppCredentials" do
      let(:output) { template["Outputs"]["AppCredentials"] }

      it "has an output" do
        expect(output).not_to be_nil
      end

      it "exports the secret reference" do
        expect(output["Export"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}-secret-manager-app_credentials"})
      end
    end

    context "ApiKey" do
      let(:output) { template["Outputs"]["ApiKey"] }

      it "has an output" do
        expect(output).not_to be_nil
      end

      it "exports the secret reference" do
        expect(output["Export"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}-secret-manager-api_key"})
      end
    end

    context "DbPassword" do
      let(:output) { template["Outputs"]["DbPassword"] }

      it "has an output" do
        expect(output).not_to be_nil
      end

      it "exports the secret reference" do
        expect(output["Export"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}-secret-manager-db_password"})
      end
    end

  end

end
