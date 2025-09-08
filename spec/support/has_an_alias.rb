# frozen_string_literal: true

# :nocov:
RSpec.shared_examples "has an alias" do |aliased_name, original_name|
  describe "##{aliased_name}" do
    it "is an alias of ##{original_name}" do
      expect(described_class.instance_method(aliased_name).original_name).to eq original_name
    end
  end
end
# :nocov:
