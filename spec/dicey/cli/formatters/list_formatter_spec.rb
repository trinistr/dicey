# frozen_string_literal: true

require "dicey/cli/formatters/list_formatter"

module Dicey
  RSpec.describe CLI::Formatters::ListFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns a string with key-value pairs with hash rockets separated by newlines" do
        expect(formatter.call({ a: 1, b: 2, c: 3 })).to eq <<~TEXT
          a => 1
          b => 2
          c => 3
        TEXT
      end
    end

    context "with `description` argument" do
      it "returns a string, prefixed with the description comment" do
        expect(formatter.call({ a: 1, b: 2, c: 3 }, "Very Important Data")).to eq <<~TEXT
          # Very Important Data
          a => 1
          b => 2
          c => 3
        TEXT
      end
    end
  end
end
