# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::BruteForce do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) do
      [
        NumericDie.new([0.1, 0.2, 0.3]),
        NumericDie.new([-1, -5]),
        RegularDie.new(3),
      ]
    end

    context "when called with valid no-overlap dice" do
      it "calculates frequencies correctly" do
        expect(result).to eq({
          -3.9 => 1,
          -3.8 => 1,
          -3.7 => 1,
          -2.9 => 1,
          -2.8 => 1,
          -2.7 => 1,
          -1.9 => 1,
          -1.8 => 1,
          -1.7 => 1,
          0.1 => 1,
          0.2 => 1,
          0.3 => 1,
          1.1 => 1,
          1.2 => 1,
          1.3 => 1,
          2.1 => 1,
          2.2 => 1,
          2.3 => 1,
        })
      end
    end

    context "when called with valid overlap dice" do
      before { dice[0] = RegularDie.new(2) }

      it "calculates frequencies correctly" do
        expect(result).to eq({ -3 => 1, -2 => 2, -1 => 2, 0 => 1, 1 => 1, 2 => 2, 3 => 2, 4 => 1 })
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
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

      context "when called with a list of any numeric dice" do
        let(:dice) { NumericDie.from_list([-0.5, 1, 2.5], [1, 2, 5]) }

        it { is_expected.to be true }
      end

      context "when called with a list of any dice" do
        let(:dice) { AbstractDie.from_list([1, 2, 3], ["a", 2, :"3"]) }

        it { is_expected.to be false }
      end
    end
  end
end
