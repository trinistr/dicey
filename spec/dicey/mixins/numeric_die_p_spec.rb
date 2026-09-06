# frozen_string_literal: true

module Dicey
  RSpec.describe Mixins::NumericDieP do
    include described_class

    it "returns true for any NumericDie" do
      expect(numeric_die?(NumericDie.new([1, 2.0, 3.1]))).to eq true
      expect(numeric_die?(RegularDie.new(3))).to eq true
    end

    it "returns true for all-Numeric dice" do
      expect(numeric_die?(AbstractDie.new([1, 2.0, 3.3]))).to eq true
      expect(numeric_die?(StaticDie.new(-3000))).to eq true
    end

    it "returns false for non-NumericDie" do
      expect(numeric_die?(AbstractDie.new([1, 2, "3"]))).to eq false
      expect(numeric_die?(StaticDie.new("a"))).to eq false
    end
  end
end
