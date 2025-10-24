# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionCalculators::RegularMultinomial do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) { RegularDie.from_count(2, 3) }

    context "when called with valid dice" do
      it "calculates weights correctly" do
        expect(result).to eq({ 2 => 1, 3 => 2, 4 => 3, 5 => 2, 6 => 1 })
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    context "when called with different numeric dice" do
      before { dice << RegularDie.new(4) }

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

      context "when called with a list of equal regular dice" do
        let(:dice) { RegularDie.from_count(2, 3) }

        it { is_expected.to be true }
      end

      context "when called with a list of arbitrary regular dice" do
        let(:dice) { [RegularDie.new(4), RegularDie.new(6)] }

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
