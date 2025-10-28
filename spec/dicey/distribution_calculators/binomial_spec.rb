# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionCalculators::Binomial do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) { AbstractDie.from_count(3, %i[a z]) }

    describe "equal two-sided dice" do
      context "when called with RegularDie" do
        let(:dice) { RegularDie.from_count(5, 2) }

        it "calculates weights correctly" do
          expect(result).to eq({ 5 => 1, 6 => 5, 7 => 10, 8 => 10, 9 => 5, 10 => 1 })
        end
      end

      context "when called with NumericDie" do
        let(:dice) { NumericDie.from_count(4, [5, 6.5r]) }

        it "calculates weights correctly" do
          expect(result).to eq({ 20r => 1, 21.5r => 4, 23r => 6, 24.5r => 4, 26r => 1 })
        end
      end

      context "when called with AbstractDie" do
        it "calculates weights correctly" do
          a = VectorNumber[:a]
          z = VectorNumber[:z]
          expect(result).to eq({ a * 3 => 1, (a * 2) + z => 3, a + (z * 2) => 3, z * 3 => 1 })
        end
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    describe "#valid_for?" do
      subject(:validity) { calculator.valid_for?(dice) }

      context "when called with one die" do
        it { is_expected.to be true }

        context "when vector_number is not available" do
          before { hide_const("VectorNumber") }

          it "returns true" do
            expect(validity).to be true
          end
        end
      end

      context "when called with many equal two-sided dice" do
        let(:dice) { NumericDie.from_count(5, [0, 1]) }

        it { is_expected.to be true }
      end

      context "when called with different twos-sided dice" do
        let(:dice) { [NumericDie.new([0, 1]), NumericDie.new([0, 2])] }

        it { is_expected.to be false }
      end
    end

    describe "#heuristic_complexity" do
      subject(:complexity) { calculator.heuristic_complexity(dice) }

      let(:dice) { RegularDie.from_count(5, 2) }

      it "returns an integer" do
        expect(complexity).to be_a(Integer)
      end

      it "increases with number of dice" do
        expect(complexity).to be > calculator.heuristic_complexity([dice.first])
      end
    end
  end
end
