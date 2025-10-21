# frozen_string_literal: true

Dir["../distribution_calculators/*.rb", base: __dir__].each { require_relative _1 }

module Dicey
  module CLI
    # A simple testing facility for roll frequency calculators.
    class CalculatorTestRunner
      AVAILABLE_CALCULATORS = DistributionCalculators::AutoSelector::AVAILABLE_CALCULATORS

      # These are manually calculated frequencies,
      # with test cases for pretty much all variations of what this program can handle.
      TEST_DATA = [
        [[1], { 1 => 1 }],
        [[10], { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1, 7 => 1, 8 => 1, 9 => 1, 10 => 1 }],
        [[2, 2], { 2 => 1, 3 => 2, 4 => 1 }],
        [[3, 3], { 2 => 1, 3 => 2, 4 => 3, 5 => 2, 6 => 1 }],
        [[4, 4], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 3, 7 => 2, 8 => 1 }],
        [[9, 9],
         { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5, 7 => 6, 8 => 7, 9 => 8, 10 => 9,
           11 => 8, 12 => 7, 13 => 6, 14 => 5, 15 => 4, 16 => 3, 17 => 2, 18 => 1 }],
        [[2, 2, 2], { 3 => 1, 4 => 3, 5 => 3, 6 => 1 }],
        [[3, 3, 3], { 3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1 }],
        [[2, 2, 2, 2], { 4 => 1, 5 => 4, 6 => 6, 7 => 4, 8 => 1 }],
        [[1, 2, 3], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
        [[3, 2, 1], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
        [[[0], 1], { 1 => 1 }],
        [[4, 6], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 4, 7 => 4, 8 => 3, 9 => 2, 10 => 1 }],
        [[[3, 17, 21]], { 3 => 1, 17 => 1, 21 => 1 }],
        [[[3, 3, 3, 3, 3, 5, 5, 5]], { 3 => 5, 5 => 3 }],
        [[[1, 4, 6], [1, 4, 6]], { 2 => 1, 5 => 2, 7 => 2, 8 => 1, 10 => 2, 12 => 1 }],
        [[[3, 4, 3], [1, 3, 2]], { 4 => 2, 5 => 3, 6 => 3, 7 => 1 }],
        [[[0, 0], [0, 0, 0], [0], [0, 0, 0, 0]], { 0 => 24 }],
        [[[0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], { 0 => 12 }],
        [[[-0.5, 0.5, 1], 6],
         { 0.5 => 1, 1.5 => 2, 2 => 1, 2.5 => 2, 3 => 1, 3.5 => 2, 4 => 1,
           4.5 => 2, 5 => 1, 5.5 => 2, 6 => 1, 6.5 => 1, 7 => 1 }],
        [Array.new(3) { [-0.25, 0.0, 0.25, 0.5, 0.75] },
         { -0.75 => 1, -0.5 => 3, -0.25 => 6, 0.0 => 10, 0.25 => 15, 0.5 => 18, 0.75 => 19,
           1.0 => 18, 1.25 => 15, 1.5 => 10, 1.75 => 6, 2.0 => 3, 2.25 => 1 }],
        [[[1.i, 2.i, 3.i], [1, 2, 3]],
         { Complex(1, 1) => 1, Complex(2, 1) => 1, Complex(3, 1) => 1,
           Complex(1, 2) => 1, Complex(2, 2) => 1, Complex(3, 2) => 1,
           Complex(1, 3) => 1, Complex(2, 3) => 1, Complex(3, 3) => 1 }],
        *(
          # :nocov:
          if defined?(VectorNumber)
            # :nocov:
            [
              [[["s", "a", "d", 33]],
               { VectorNumber["s"] => 1, VectorNumber["a"] => 1, VectorNumber["d"] => 1, 33 => 1 }],
              [[%w[s a d], [0, 1, 2]],
               { VectorNumber["s"] => 1, VectorNumber["s", 1] => 1, VectorNumber["s", 2] => 1,
                 VectorNumber["a"] => 1, VectorNumber["a", 1] => 1, VectorNumber["a", 2] => 1,
                 VectorNumber["d"] => 1, VectorNumber["d", 1] => 1, VectorNumber["d", 2] => 1 }],
              [Array.new(2) { ["s", "a", 4] },
               {
                 VectorNumber["s"] * 2 => 1, VectorNumber["a"] * 2 => 1, 8 => 1,
                 VectorNumber["s", "a"] => 2, VectorNumber["s", 4] => 2, VectorNumber["a", 4] => 2,
               }],
            ]
          end
        ),
      ].freeze

      # Strings for displaying test results.
      RESULT_TEXT = { pass: "✔", fail: "✘ 🠐 failure!", skip: "☂", crash: "⛐ 🠐 crash!" }.freeze
      # Which test results are considered failures.
      FAILURE_RESULTS = %i[fail crash].freeze

      # Check all tests defined in {TEST_DATA} with every passed calculator.
      #
      # @param report_style [Symbol] one of: +:full+, +:quiet+;
      #   +:quiet+ style does not output any text
      # @return [Boolean] whether there are no failing tests
      def call(*, report_style:, **)
        results = TEST_DATA.to_h { |test| run_test(test) }
        full_report(results) if report_style == :full
        results.values.none? do |test_result|
          test_result.values.any? { FAILURE_RESULTS.include?(_1) }
        end
      end

      private

      # @param test [Array(Array<Integer, Array<Numeric>>, Hash{Numeric => Integer})]
      #   pair of a dice list definition and expected results
      # @return [Array(Array<NumericDie>, Hash{BaseCalculator => Symbol})]
      #   result of running the test in a format suitable for +#to_h+
      def run_test(test)
        dice = build_dice(test.first)
        test_result =
          AVAILABLE_CALCULATORS.each_with_object({}) do |calculator, hash|
            hash[calculator] = run_test_on_calculator(calculator, dice, test.last)
          end
        [dice, test_result]
      end

      # Build a list of {NumericDie} objects from a plain definition.
      #
      # @param definition [Array<Integer, Array<Integer>>]
      # @return [Array<NumericDie>]
      def build_dice(definition)
        definition.map do |die_def|
          if die_def.is_a?(Integer)
            RegularDie.new(die_def)
          elsif die_def.all?(Numeric)
            NumericDie.new(die_def)
          else
            AbstractDie.new(die_def)
          end
        end
      end

      # Determine test result for the selected calculator.
      def run_test_on_calculator(calculator, dice, expectation)
        return :skip unless calculator.valid_for?(dice)

        (calculator.call(dice) == expectation) ? :pass : :fail
      rescue
        :crash
      end

      # Print results of running all tests.
      def full_report(results)
        results.each do |dice, test_result|
          print "#{AbstractDie.describe(dice)}:\n"
          test_result.each do |calculator, result|
            print "  #{calculator.class}: "
            puts RESULT_TEXT[result]
          end
        end
      end
    end
  end
end
