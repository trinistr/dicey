# frozen_string_literal: true

module Dicey
  RSpec.describe SumFrequencyCalculators::BaseCalculator do
    subject(:result) { calculator.call(dice, result_type: result_type) }

    let(:calculator) { implementation.new }
    let(:implementation) do
      Class.new(described_class) do
        def calculate(dice)
          # Fake calculation, add 1 result for each side.
          dice.map(&:sides_num).reduce(:*).times.to_h { |n| [n, 1] }
        end

        private

        def calculate_heuristic(dice_count, sides_count)
          dice_count * sides_count
        end
      end
    end

    let(:dice) { AbstractDie.from_count(2, ["a", 2, :"3"]) }
    let(:result_type) { :frequencies }

    context "when called on its own, not an implementation" do
      let(:calculator) { described_class.new }

      it "raises NotImplementedError" do
        expect { result }.to raise_error(NotImplementedError)
      end
    end

    context "if dice list is empty" do
      let(:dice) { [] }

      it "returns empty hash" do
        expect(result).to eq({})
      end
    end

    context "when frequencies are requested" do
      it "calcualtes frequencies for each outcome" do
        expect(result).to eq(
          { 0 => 1, 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1, 7 => 1, 8 => 1 }
        )
      end
    end

    context "when probabilities are requested" do
      let(:result_type) { :probabilities }

      it "calcualtes probabilities for each outcome using Rational" do
        p = 1/9r
        expect(result).to eq(
          { 0 => p, 1 => p, 2 => p, 3 => p, 4 => p, 5 => p, 6 => p, 7 => p, 8 => p }
        )
        expect(result.values).to all be_a Rational
      end
    end

    context "when result_type is invalid" do
      let(:result_type) { :invalid }

      it "raises DiceyError" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    context "if implementation is invalid for dice given" do
      let(:implementation) do
        Class.new(described_class) do
          def valid_for?(*)
            false
          end
        end
      end

      it "raises DiceyError" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    context "if calculator returns obviously wrong results" do
      let(:implementation) do
        Class.new(described_class) do
          def calculate(*)
            { 0 => 1 }
          end
        end
      end

      it "raises DiceyError" do
        expect { result }.to raise_error(DiceyError)
      end
    end

    describe "#valid_for?" do
      subject(:validity) { calculator.valid_for?(dice) }

      context "when called with a list of valid dice" do
        let(:dice) { AbstractDie.from_count(2, ["a", 2, :"3"]) }

        it { is_expected.to be true }
      end

      context "when called with a non-Enumerable" do
        let(:dice) { RegularDie.new(3) }

        it { is_expected.to be false }
      end

      context "when called with non-dice" do
        let(:dice) { ["a", 2, :"3"] }

        it { is_expected.to be false }
      end

      context "when implementation is valid only for some dice" do
        let(:implementation) do
          Class.new(described_class) do
            def validate(dice)
              dice.all?(RegularDie)
            end
          end
        end

        context "and given those dice" do
          let(:dice) { RegularDie.from_count(3, 6) }

          it { is_expected.to be true }
        end

        context "and given other dice" do
          let(:dice) { AbstractDie.from_count(3, ["a", 2, :"3"]) }

          it { is_expected.to be false }
        end
      end
    end

    describe "#heuristic_complexity" do
      subject(:complexity) { calculator.heuristic_complexity(dice) }

      it { is_expected.to be_a Integer }

      context "when called on its own, not an implementation" do
        let(:calculator) { described_class.new }

        it "raises NotImplementedError" do
          expect { complexity }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
