# frozen_string_literal: true

module Dicey
  RSpec.describe DistributionCalculators::Empirical do
    subject(:result) { calculator.call(dice, rolls: 1000) }

    let(:calculator) { described_class.new }

    let(:dice) do
      [
        NumericDie.new([0.25, 0.5, 0.75]),
        AbstractDie.new([-1, -5]),
        RegularDie.new(3),
      ]
    end

    context "when called with valid no-overlap dice" do
      it "calculates weights correctly" do
        expect(result).to match({
          -3.75 => a_value_within(0.5).of(1),
          -3.5 => a_value_within(0.5).of(1),
          -3.25 => a_value_within(0.5).of(1),
          -2.75 => a_value_within(0.5).of(1),
          -2.5 => a_value_within(0.5).of(1),
          -2.25 => a_value_within(0.5).of(1),
          -1.75 => a_value_within(0.5).of(1),
          -1.5 => a_value_within(0.5).of(1),
          -1.25 => a_value_within(0.5).of(1),
          0.25 => a_value_within(0.5).of(1),
          0.5 => a_value_within(0.5).of(1),
          0.75 => a_value_within(0.5).of(1),
          1.25 => a_value_within(0.5).of(1),
          1.50 => a_value_within(0.5).of(1),
          1.75 => a_value_within(0.5).of(1),
          2.25 => a_value_within(0.5).of(1),
          2.5 => a_value_within(0.5).of(1),
          2.75 => a_value_within(0.5).of(1),
        })
      end
    end

    context "when called with valid overlap dice" do
      before { dice[0] = RegularDie.new(2) }

      it "calculates weights correctly" do
        expect(result).to match({
          -3 => a_value_within(0.5).of(1),
          -2 => a_value_within(0.5).of(2),
          -1 => a_value_within(0.5).of(2),
          0 => a_value_within(0.5).of(1),
          1 => a_value_within(0.5).of(1),
          2 => a_value_within(0.5).of(2),
          3 => a_value_within(0.5).of(2),
          4 => a_value_within(0.5).of(1),
        })
      end
    end

    context "when vector_number is not available" do
      before { hide_const("VectorNumber") }

      it "does not support AbstractDie" do
        expect { result }.to(output(/"vector_number"/).to_stderr.and(raise_error DiceyError))
      end

      it "supports NumericDie" do
        dice[1] = NumericDie.new([-1, 5])
        expect { result }.not_to output.to_stderr
        expect(result).to be_a Hash
      end
    end

    context "when called with an explicit 'rolls' option" do
      subject(:result) { calculator.call(dice, rolls: 1) }

      it "rolls the specified number of times" do
        expect(result.size).to be 1
      end
    end

    context "when called with an empty list of dice" do
      let(:dice) { [] }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    context "when called with non-numeric dice" do
      before { dice[0] = AbstractDie.new(%w[s n a k]) }

      context "with available vector_number" do
        it "calculates results with VectorNumber" do
          expect(result).to include(
            VectorNumber["s", -4] => Rational,
            VectorNumber["s", -3] => Rational,
            VectorNumber["s", -2] => Rational,
            VectorNumber["s"] => Rational,
            VectorNumber["s", 1] => Rational,
            VectorNumber["s", 2] => Rational
          )
          expect(result).to include(VectorNumber["n"] => Rational)
          expect(result).to include(VectorNumber["a", 2] => Rational)
          expect(result).to include(VectorNumber["k", -3] => Rational)
        end
      end

      context "when vector_number is not available" do
        before { hide_const("VectorNumber") }

        it "raises an error and prints a warning" do
          expect { result }.to raise_error(DiceyError).and output(/"vector_number"/).to_stderr
        end
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

        context "with available vector_number" do
          it { is_expected.to be true }
        end

        context "when vector_number is not available" do
          before { hide_const("VectorNumber") }

          it "prints a warning and returns false" do
            expect { validity }.to output(/"vector_number"/).to_stderr
            expect(validity).to be false
          end
        end
      end
    end

    describe "#heuristic_complexity" do
      subject(:complexity) { calculator.heuristic_complexity(dice) }

      let(:dice) { AbstractDie.from_list([-0.5, 1, 2.5], %w[1 2 5]) }

      it "returns an integer" do
        expect(complexity).to be_a(Integer)
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
