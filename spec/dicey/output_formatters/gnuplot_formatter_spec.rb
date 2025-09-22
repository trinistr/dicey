# frozen_string_literal: true

module Dicey
  RSpec.describe OutputFormatters::GnuplotFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns a string with key-value pairs with spaces separated by newlines" do
        expect(formatter.call({ a: 1, b: 2, c: 3 })).to eq <<~TEXT
          a 1
          b 2
          c 3
        TEXT
      end
    end

    context "with `description` argument" do
      it "returns a string, prefixed with the description comment" do
        expect(formatter.call({ a: 1, b: 2, c: 3 }, "Very Important Data")).to eq <<~TEXT
          # Very Important Data
          a 1
          b 2
          c 3
        TEXT
      end
    end

    context "with Rational probabilities" do
      it "returns pairs with floating-point probabilities" do
        expect(formatter.call({ a: 1/2r, b: 1/4r, c: 1/4r })).to eq <<~TEXT
          a 0.5
          b 0.25
          c 0.25
        TEXT
      end
    end
  end
end
