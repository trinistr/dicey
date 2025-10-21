# frozen_string_literal: true

require "dicey/cli/formatters/yaml_formatter"
require "yaml"

module Dicey
  RSpec.describe CLI::Formatters::YAMLFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns a string with YAML data" do
        expect(formatter.call({ a: 1, b: 2, c: 3 })).to eq <<~TEXT
          ---
          results:
            a: 1
            b: 2
            c: 3
        TEXT
      end
    end

    context "with `description` argument" do
      it "returns a string with YAML data, including 'description' key" do
        expect(formatter.call({ a: 1, b: 2, c: 3 }, "Very Important Data")).to eq <<~TEXT
          ---
          description: Very Important Data
          results:
            a: 1
            b: 2
            c: 3
        TEXT
      end
    end
  end
end
