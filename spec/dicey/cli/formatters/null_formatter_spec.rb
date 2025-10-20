# frozen_string_literal: true

require "dicey/cli/formatters/null_formatter"

module Dicey
  RSpec.describe CLI::Formatters::NullFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns an empty string" do
        expect(formatter.call({ a: 1, b: 2, c: 3 })).to eq ""
      end
    end

    context "with `description` argument" do
      it "returns an empty string" do
        expect(formatter.call({ a: 1, b: 2, c: 3 }, "Very Important Data")).to eq ""
      end
    end
  end
end
