# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::KroneckerSubstitution do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) { NumericDie.from_list([0, 1, 2], [3, 13, 2]) }

    context "when called with valid dice" do
      it "calculates frequencies correctly" do
        expect(result).to eq({ 2 => 1, 3 => 2, 4 => 2, 5 => 1, 13 => 1, 14 => 1, 15 => 1 })
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    context "when called with negative numeric dice" do
      before { dice << NumericDie.new([-1, 2, 3]) }

      it "rejects them" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    context "when called with non-integer numeric dice" do
      before { dice << NumericDie.new([0.5, 2, 3]) }

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

      context "when called with a list of regular dice" do
        let(:dice) { RegularDie.from_count(2, 5) }

        it { is_expected.to be true }
      end

      context "when called with a list of non-negative integer dice" do
        let(:dice) { NumericDie.from_list([0, 1, 2], [3, 13], [1, 768, 0]) }

        it { is_expected.to be true }
      end

      context "when called with a list of arbitrary numeric dice" do
        let(:dice) { NumericDie.from_count(2, [-0.5, 1, 3]) }

        it { is_expected.to be false }
      end

      context "when called with a list of non-numeric dice" do
        let(:dice) { AbstractDie.from_count(2, ["a", 2, :"3"]) }

        it { is_expected.to be false }
      end
    end
  end
end
