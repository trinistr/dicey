# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::MultinomialCoefficients do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) { NumericDie.from_count(2, [-0.5, 1, 2.5]) }

    context "when called with valid dice" do
      it "calculates frequencies correctly" do
        expect(result).to eq({ -1.0 => 1, 0.5 => 2, 2.0 => 3, 3.5 => 2, 5.0 => 1 })
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    context "when called with different numeric dice" do
      before { dice << NumericDie.new([1, 2, 3]) }

      it "rejects them" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    context "when called with non-numeric dice" do
      before { dice << AbstractDie.new(%w[s n a k e]) }

      it "rejects them" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    describe "#valid_for?" do
      subject(:validity) { calculator.valid_for?(dice) }

      context "when called with a list of equal arithmetic dice" do
        let(:dice) { NumericDie.from_count(2, [-0.5, 1, 2.5]) }

        it { is_expected.to be true }
      end

      context "when called with a list of arbitrary numeric dice" do
        let(:dice) { NumericDie.from_count(2, [-0.5, 1, 3]) }

        it { is_expected.to be false }
      end

      context "when called with a list of different numeric dice" do
        let(:dice) { NumericDie.from_list([-0.5, 1, 2.5], [1, 2, 3]) }

        it { is_expected.to be false }
      end

      context "when called with a list of non-numeric dice" do
        let(:dice) { AbstractDie.from_count(2, ["a", 2, :"3"]) }

        it { is_expected.to be false }
      end
    end

    describe "#heuristic_complexity" do
      subject(:complexity) { calculator.heuristic_complexity(dice) }

      let(:dice) { AbstractDie.from_list([-0.5, 1, 2.5], %w[1 2 5]) }

      it "returns a positive integer" do
        expect(complexity).to be_a(Integer).and be > 0
      end

      it "increases with number of dice" do
        expect(complexity).to be > calculator.heuristic_complexity([dice.first])
      end

      it "increases with number of sides" do
        expect(complexity).to be > calculator.heuristic_complexity(
          dice.map { _1.class.new(_1.sides_list[1..]) }
        )
      end
    end
  end
end
