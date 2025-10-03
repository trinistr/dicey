# frozen_string_literal: true

module Dicey
  RSpec.describe Complex do
    subject(:properties) { {} }

    context "when distribution is complex" do
      let(:distribution) { { 1i => 2, 2 => 3, Complex(2, 3) => 2, Complex(1, 4) => 3 } }

      it "returns all properties which don't depend on ordering" do
        expect(properties).to include(
          mode: [2, 1 + 4i],
          arithmetic_mean: (5/4r) + 2i,
          expected_value: (13/10r) + 2i,
          variance: (-219/100r) - (2/5r).i
        )
        expect(properties).to include(:standard_deviation, :skewness, :kurtosis, :excess_kurtosis)
      end
    end
  end
end