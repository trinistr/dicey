# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionCalculators::Trivial do
    subject(:result) { calculator.call(dice) }

    let(:calculator) { described_class.new }

    let(:dice) { [AbstractDie.new([1, 1, 2, "a", "a", "b"])] }

    describe "one die" do
      it "tallies its sides using VectorNumber" do
        expect(result).to eq(
          { 1 => 2, 2 => 1, VectorNumber.new(["a"]) => 2, VectorNumber.new(["b"]) => 1 }
        )
      end

      context "when vector_number is not available" do
        before { hide_const("VectorNumber") }

        it "tallies its sides anyway" do
          expect(result).to eq({ 1 => 2, 2 => 1, "a" => 2, "b" => 1 })
        end
      end

      context "when die is RegularDie" do
        let(:dice) { [RegularDie.new(6)] }

        it "tallies its sides" do
          expect(result).to eq({ 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1 })
        end
      end
    end

    describe "two equal regular dice" do
      let(:dice) { RegularDie.from_count(2, 6) }

      it "calculates weights correctly" do
        expect(result).to eq({ 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5, 7 => 6, 8 => 5, 9 => 4,
                               10 => 3, 11 => 2, 12 => 1 })
      end

      context "when called with three equal regular dice" do
        let(:dice) { RegularDie.from_count(3, 6) }

        it "raises DiceyError" do
          expect { result }.to raise_error(DiceyError)
        end
      end
    end

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
        let(:dice) { AbstractDie.from_count(3, %i[a z]) }

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

      context "when called with two equal regular dice" do
        let(:dice) { [RegularDie.new(2), RegularDie.new(2)] }

        it { is_expected.to be true }
      end
    end

    describe "#heuristic_complexity" do
      subject(:complexity) { calculator.heuristic_complexity(dice) }

      let(:dice) { [RegularDie.new(6), RegularDie.new(6)] }

      it "returns a positive integer" do
        expect(complexity).to be_a(Integer).and be > 0
      end

      it "increases with number of dice" do
        expect(complexity).to be > calculator.heuristic_complexity([dice.first])
      end

      it "increases with number of sides" do
        expect(complexity).to be > calculator.heuristic_complexity(
          dice.map { _1.class.new(_1.sides_list.last - 1) }
        )
      end
    end
  end
end
