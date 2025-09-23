# frozen_string_literal: true

module Dicey
  RSpec.describe OutputFormatters::GnuplotFormatter do
    subject(:formatter) { described_class.new }

    context "without `description` argument" do
      it "returns a string with key-value pairs with spaces separated by newlines" do
        expect(formatter.call({ 3 => 1, 4 => 2, 5 => 3 })).to eq <<~TEXT
          3 1
          4 2
          5 3
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

    context "with Rational values" do
      it "returns pairs with floating-point values" do
        expect(formatter.call({ 3/10r => 1/2r, 4/10r => 1/4r, 5/10r => 1/4r })).to eq <<~TEXT
          0.3 0.5
          0.4 0.25
          0.5 0.25
        TEXT
      end
    end
  end
end
