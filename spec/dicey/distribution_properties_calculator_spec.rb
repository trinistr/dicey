# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionPropertiesCalculator do
    subject(:properties) { calculator.call(distribution) }

    let(:calculator) { described_class.new }

    context "when distribution is empty" do
      let(:distribution) { {} }

      it "returns an empty hash" do
        expect(properties).to eq({})
      end
    end

    context "when distribution has only a single real-valued point" do
      let(:distribution) { { 37 => 1 } }

      it "returns properties with trivial values, some of them undefined" do
        expect(properties).to eq(
          mode: [37],
          min: 37,
          max: 37,
          mid_range: 37,
          total_range: 0,
          median: 37,
          arithmetic_mean: 37,
          expected_value: 37,
          variance: 0,
          standard_deviation: 0,
          skewness: nil,
          kurtosis: nil,
          excess_kurtosis: nil
        )
      end
    end

    context "when distribution is uniform" do
      let(:distribution) { { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1 } }

      it "returns expected values for properties" do
        expect(properties).to eq(
          mode: [1, 2, 3, 4, 5, 6],
          min: 1,
          max: 6,
          mid_range: (7/2r),
          total_range: 5,
          median: (7/2r),
          arithmetic_mean: (7/2r),
          expected_value: (7/2r),
          variance: (35/12r),
          standard_deviation: Math.sqrt(35/12r),
          skewness: 0,
          kurtosis: (303/175r),
          excess_kurtosis: (-222/175r)
        )
      end
    end

    context "when distribution is asymmetric" do
      let(:distribution) { { 1 => 1, 2 => 3, 3 => 2, 4 => 5, 5 => 1, 60 => 2 } }

      it "returns expected values for properties" do
        expect(properties).to match(
          mode: [4],
          min: 1,
          max: 60,
          mid_range: (61/2r),
          total_range: 59,
          median: (7/2r),
          arithmetic_mean: (75/6r),
          expected_value: (158/14r),
          variance: a_value_within(0.00000001).of(396.63265306),
          standard_deviation: a_value_within(0.00000001).of(Math.sqrt(396.63265306)),
          skewness: a_value_within(0.00000001).of(2.02910507),
          kurtosis: a_value_within(0.00000001).of(5.14047263),
          excess_kurtosis: a_value_within(0.00000001).of(2.14047263)
        )
      end
    end

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

    context "when distribution includes non-numeric values" do
      let(:distribution) { { "a" => 3, 2 => 2, "c" => 2, 4 => 3, "e" => 2, 6 => 3 } }

      it "returns only mode" do
        expect(properties).to eq(mode: ["a", 4, 6])
      end
    end

    context "when distribution includes non-sortable values" do
      let(:distribution) { { "a" => 1, {} => 2, 3 => 3 } }

      it "returns only mode" do
        expect(properties).to eq(mode: [3])
      end
    end
  end
end
