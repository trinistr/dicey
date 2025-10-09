# frozen_string_literal: true

module Dicey
  RSpec.describe Mixins::RationalToInteger do
    include described_class

    it "converts rationals with denominator of 1 to integers" do
      expect(rational_to_integer(Rational(1, 1))).to eq 1
      expect(rational_to_integer(Rational(2, 1))).to eq 2
      expect(rational_to_integer(Rational(3, 1))).to eq 3
    end

    it "returns value as-is if it's not a rational with denominator of 1" do
      expect(rational_to_integer(1.5)).to eq 1.5
      expect(rational_to_integer(1/2r)).to eq 1/2r
      expect(rational_to_integer("3")).to eq "3"
    end
  end
end
