# frozen_string_literal: true

require "dicey/mixins/missing_math"

module Dicey
  RSpec.describe Mixins::MissingMath do
    include described_class

    shared_examples "has module_function method" do |name|
      it "defines public method on module itself" do
        expect(described_class.public_methods(false)).to include name
      end

      it "defines private method on instance" do
        expect(described_class.private_instance_methods(false)).to include name
      end
    end

    describe "#combinations" do
      include_examples "has module_function method", :combinations

      it "returns correct number of combinations" do
        expect(combinations(2, 1)).to eq 2
        expect(combinations(3, 2)).to eq 3
        expect(combinations(5, 2)).to eq 10
        expect(combinations(6, 3)).to eq 20
      end

      it "returns 0 if k is greater than n" do
        expect(combinations(5, 6)).to eq 0
      end

      it "returns 1 if k is 0 or n" do
        expect(combinations(5, 0)).to eq 1
        expect(combinations(5, 5)).to eq 1
      end
    end

    describe "#factorial" do
      include_examples "has module_function method", :factorial

      it "returns correct values for small numbers" do
        expect(factorial(0)).to eq 1
        expect(factorial(1)).to eq 1
        expect(factorial(5)).to eq 120
        expect(factorial(6)).to eq 720
      end

      it "returns correct values for large numbers" do
        expect(factorial(22)).to eq 1_124_000_727_777_607_680_000
        expect(factorial(23)).to eq 1_124_000_727_777_607_680_000 * 23
        expect(factorial(24)).to eq 1_124_000_727_777_607_680_000 * 23 * 24
      end
    end

    describe "#factorial_quo" do
      include_examples "has module_function method", :factorial_quo

      it "returns correct values for small numbers" do
        expect(factorial_quo(4, 3)).to eq 4
        expect(factorial_quo(5, 2)).to eq 60
      end

      it "returns correct values for large numbers" do
        expect(factorial_quo(22, 12)).to eq 13 * 14 * 15 * 16 * 17 * 18 * 19 * 20 * 21 * 22
        expect(factorial_quo(24, 18)).to eq 19 * 20 * 21 * 22 * 23 * 24
        expect(factorial_quo(60, 55)).to eq 56 * 57 * 58 * 59 * 60
      end

      it "returns correct values for special cases" do
        expect(factorial_quo(0, 0)).to eq 1
        expect(factorial_quo(5, 0)).to eq 120
        expect(factorial_quo(5, 5)).to eq 1
      end
    end
  end
end
