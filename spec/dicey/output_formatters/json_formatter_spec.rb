# frozen_string_literal: true

require "json"

module Dicey
  RSpec.describe OutputFormatters::JSONFormatter do
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
  end
end
