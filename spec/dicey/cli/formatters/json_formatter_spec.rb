# frozen_string_literal: true

require "dicey/cli/formatters/json_formatter"
require "json"

module Dicey
  RSpec.describe CLI::Formatters::JSONFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns a string with JSON data" do
        expect(formatter.call({ a: 1, b: 2, c: 3 })).to eq <<~TEXT.chomp
          {"results":{"a":1,"b":2,"c":3}}
        TEXT
      end
    end

    context "with `description` argument" do
      it "returns a string with JSON data, including 'description' key" do
        expect(formatter.call({ a: 1, b: 2, c: 3 }, "Very Important Data")).to eq <<~TEXT.chomp
          {"description":"Very Important Data","results":{"a":1,"b":2,"c":3}}
        TEXT
      end
    end

    context "with Rational values" do
      it "returns JSON with floating-point values" do
        expect(formatter.call({ 3/10r => 1/2r, 4/10r => 1/4r, 5/10r => 1/4r })).to eq <<~TEXT.chomp
          {"results":{"0.3":0.5,"0.4":0.25,"0.5":0.25}}
        TEXT
      end
    end
  end
end
