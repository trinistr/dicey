# frozen_string_literal: true

module Dicey
  RSpec.describe OutputFormatters::NullFormatter do
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
