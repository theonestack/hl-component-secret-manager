require 'yaml'

describe 'compiled component secret-manager' do

  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end
  end

  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/secret-manager.compiled.yaml") }

  context "Resource" do

    context "DefaultSecret" do
      let(:resource) { template["Resources"]["DefaultSecret"] }

      it "is of type AWS::SecretsManager::Secret" do
        expect(resource["Type"]).to eq("AWS::SecretsManager::Secret")
      end

      it "to have property GenerateSecretString" do
        expect(resource["Properties"]["GenerateSecretString"]).to include(
          "GenerateStringKey" => "password",
          "SecretStringTemplate" => '{"username":"admin"}',
          "PasswordLength" => 32,
          "RequireEachIncludedType" => true
        )
      end

      it "to have property Name" do
        expect(resource["Properties"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}/default-secret"})
      end

      it "to have property Tags" do
        expect(resource["Properties"]["Tags"]).to include(
          {"Key" => "Name", "Value" => {"Fn::Sub" => "${EnvironmentName}-secret-manager"}},
          {"Key" => "Environment", "Value" => {"Ref" => "EnvironmentName"}},
          {"Key" => "EnvironmentType", "Value" => {"Ref" => "EnvironmentType"}}
        )
      end
    end

  end

  context "Outputs" do

    context "DefaultSecret" do
      let(:output) { template["Outputs"]["DefaultSecret"] }

      it "has an output" do
        expect(output).not_to be_nil
      end

      it "exports the secret reference" do
        expect(output["Export"]["Name"]).to eq({"Fn::Sub" => "${EnvironmentName}-secret-manager-default_secret"})
      end
    end

  end

end
