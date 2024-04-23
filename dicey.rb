#!/usr/bin/env ruby
# frozen_string_literal: true

# A little program to calculate frequencies (tallies) of each possible result
# for a throw of a given collection of dice, drawing result with `gnuplot`.
# Using dice with exactly equal number of sides is significantly faster.

# Usage: dicey.rb 4 4 4 # calculate frequencies for three 4-sided dice
# Usage: dicey.rb 3 6 # calculate frequencies for a pair of 3-sided and 6-sided dice
# Usage: ruby -r './dicey' -e 'puts Dicey::RegularDie.new(5).roll' # roll a D5

# A library for rolling dice and calculating roll frequencies.
module Dicey
  VERSION = '0.6.1'

  # Asbtract die which may have an arbitrary list of sides,
  # not even neccessarily numbers (but preferably so).
  class AbstractDie
    attr_reader :sides_list, :sides_num, :enum

    class << self
      # Get a text representation of a list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [String]
      def describe(dice)
        dice.join(';')
      end
    end

    # @param sides_list [Enumerable<Object>]
    def initialize(sides_list)
      @sides_list = sides_list.dup.freeze
      @sides_num = @sides_list.size

      sides_enum = @sides_list.to_enum
      @enum = Enumerator.produce do
        sides_enum.next
      rescue StopIteration
        sides_enum.rewind
        retry
      end
    end

    # Get next side of the die, advancing internal enumerator state.
    # Wraps from last to first side.
    #
    # @return [Object] next side
    def next
      @enum.next
    end

    # Advance internal enumerator state by a random number using {#next}.
    #
    # @return [Object] rolled side
    def roll
      rand(0...sides_num).times { self.next }
      @enum.peek
    end

    def to_s
      "(#{sides_list.join(',')})"
    end
  end

  # Regular die, which has N sides with numbers from 1 to N.
  class RegularDie < AbstractDie
    D6 = '⚀⚁⚂⚃⚄⚅'

    class << self
      # Create a list of regular dice with the same number of sides.
      #
      # @param dice [Integer]
      # @param sides [Integer]
      # @return [Array<RegularDie>]
      def create_dice(dice, sides)
        (1..dice).map { new(sides) }
      end
    end

    # @param sides [Integer]
    def initialize(sides)
      super((1..sides))
    end

    def to_s
      sides_num <= D6.size ? D6[sides_num - 1] : "[#{sides_num}]"
    end
  end
end

module Dicey
  module SumFrequencyCalculators
    # Base frequencies calculator.
    # @abstract
    class BaseCalculator
      # @param dice [Enumerable<AbstractDie>]
      # @return [Hash{Integer => Integer}] frequencies of each sum
      # @raise [RuntimeError] if dice list is invalid for the calculator
      def call(dice)
        raise "#{self.class} can not handle these dice!" unless valid_for?(dice)

        calculate(dice)
      end

      # Whether this calculator can be used for the list of dice.
      #
      # @param dice [Enumerable<RegularDie>]
      # @return [Boolean]
      def valid_for?(dice)
        dice.is_a?(Enumerable) && dice.all? { _1.is_a?(AbstractDie) } && validate(dice)
      end

      private

      # Do additional validation on the dice list.
      # (see #valid_for?)
      def validate(_dice)
        true
      end

      # Peform frequencies calculation.
      # (see #call)
      def calculate(dice)
        raise NotImplementedError
      end
    end

    # Calculator for a collection of dice using complete iteration (slow).
    #
    # Able to handle {AbstractDie} lists with numeric sides.
    class GenericFrequenciesCalculator < BaseCalculator
      private

      def validate(dice)
        dice.all? { |die| die.sides_list.all? { _1.is_a?(Integer) } }
      end

      def calculate(dice)
        combine_dice_enumerators(dice).map(&:sum).tally
      end

      # Get an enumerator which goes through all possible permutations of dice sides.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Enumerator<Array>]
      def combine_dice_enumerators(dice)
        sides_num_list = dice.map(&:sides_num)
        total = sides_num_list.reduce(:*)
        Enumerator.new(total) do |yielder|
          current_values = dice.map(&:next)
          remaining_iterations = sides_num_list
          total.times do
            yielder << current_values
            iterate_dice(dice, remaining_iterations, current_values)
          end
        end
      end

      # Iterate through dice, getting next side for first die,
      # then getting next side for second die, resetting first die, and so on.
      # This is analogous to incrementing by 1 in a positional system
      # where each position is a die.
      def iterate_dice(dice, remaining_iterations, current_values)
        dice.each_with_index do |die, i|
          value = die.next
          current_values[i] = value
          remaining_iterations[i] -= 1
          break if remaining_iterations[i].nonzero?

          remaining_iterations[i] = die.sides_num
        end
      end
    end

    # Calculator for {RegularDie} lists with equal number of sides (fast).
    class RegularFrequenciesCalculator < BaseCalculator
      private

      def validate(dice)
        number_of_sides = dice.first.sides_num
        dice.all? { _1.is_a?(RegularDie) && _1.sides_num == number_of_sides }
      end

      def calculate(dice)
        number_of_sides = dice.first.sides_num
        min = dice.size
        max = dice.size * number_of_sides
        frequencies = multinomial_coefficients(dice.size, number_of_sides)
        (min..max).to_a.zip(frequencies).to_h
      end

      # Calculate coefficients for a multinomial of the form
      # <tt>(x^1 +...+ x^m)^n</tt>, where +m+ is the number of sides and +n+ is the number of dice.
      #
      # @param dice [Integer] must be positive
      # @param sides [Integer] must be positive
      # @param throw_away_garbage [Boolean] whether to discard unused coefficients (debug option)
      # @return [Array<Integer>]
      # @see https://en.wikipedia.org/wiki/Pascal%27s_triangle
      # @see https://en.wikipedia.org/wiki/Trinomial_triangle
      def multinomial_coefficients(dice, sides, throw_away_garbage: true)
        # This builds a triangular matrix where each first element is a 1.
        # Each element is a sum of `m` elements in the previous row with indices less or equal to its,
        # with out-of-bounds indices corresponding to 0s.
        # Example for m=3:
        # 1
        # 1 1 1
        # 1 2 3 2 1
        # 1 3 6 7 6 3 1, etc.
        coefficients = [[1]]
        (1..dice).each do |row_index|
          row = next_row_of_coefficients(row_index, sides - 1, coefficients.last)
          if throw_away_garbage
            coefficients[0] = row
          else
            coefficients << row
          end
        end
        coefficients.last
      end

      def next_row_of_coefficients(row_index, window_size, previous_row)
        length = row_index * window_size + 1
        (0..length).map do |col_index|
          # Have to clamp to 0 to prevent accessing array from the end.
          window_range = ((col_index - window_size).clamp(0..)..col_index)
          window_range.sum { |i| previous_row.fetch(i, 0) }
        end
      end
    end
  end
end

module Dicey
  module OutputFormatters
    # Base formatter for outputting lists of key-value pairs separated by newlines.
    # Can add an optional description into the result.
    # @abstract
    class KeyValueFormatter
      # @param hash [Hash{Integer => Integer}]
      # @param description [String] text to add as a comment.
      # @return [String]
      def call(hash, description = nil)
        initial_string = description ? "# #{description}\n" : String.new
        hash.each_with_object(initial_string) do |(key, value), output|
          output << "#{key}#{self.class::SEPARATOR}#{value}\n"
        end
      end
    end

    # Formats a hash as list of key => value pairs, similar to a Ruby Hash.
    class ListFormatter < KeyValueFormatter
      SEPARATOR = ' => '
    end

    # Formats a hash as a text file suitable for consumption by Gnuplot.
    class GnuplotFormatter < KeyValueFormatter
      SEPARATOR = ' '
    end

    # Base formatter for outputting in formats which can be converted from a Hash directly.
    # Can add an optional description into the result.
    # @abstract
    class HashFormatter
      # @param hash [Hash{Integer => Integer}]
      # @param description [String] text to add to result as an extra key
      # @return [String]
      def call(hash, description = nil)
        output = {}
        output['description'] = description if description
        output['results'] = hash
        output.public_send(self.class::METHOD)
      end
    end

    # Formats a hash as a YAML document under `results` key, with optional `description` key.
    class YAMLFormatter < HashFormatter
      METHOD = :to_yaml
    end

    # Formats a hash as a JSON document under `results` key, with optional `description` key.
    class JSONFormatter < HashFormatter
      METHOD = :to_json
    end
  end
end

return unless $PROGRAM_NAME == __FILE__

module Dicey
  module SumFrequencyCalculators
    # A simple testing facility for dealing with diceyness.
    class TestRunner
      # These are manually calculated frequencies,
      # with test cases for pretty much all variations of what this program can handle.
      TEST_DATA = [
        [[1], { 1 => 1 }],
        [[10], { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1, 7 => 1, 8 => 1, 9 => 1, 10 => 1 }],
        [[2, 2], { 2 => 1, 3 => 2, 4 => 1 }],
        [[3, 3], { 2 => 1, 3 => 2, 4 => 3, 5 => 2, 6 => 1 }],
        [[4, 4], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 3, 7 => 2, 8 => 1 }],
        [[2, 2, 2], { 3 => 1, 4 => 3, 5 => 3, 6 => 1 }],
        [[3, 3, 3], { 3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1 }],
        [[2, 2, 2, 2], { 4 => 1, 5 => 4, 6 => 6, 7 => 4, 8 => 1 }],
        [[1, 2, 3], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
        [[3, 2, 1], { 3 => 1, 4 => 2, 5 => 2, 6 => 1 }],
        [[4, 6], { 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 4, 7 => 4, 8 => 3, 9 => 2, 10 => 1 }],
        [[[3, 17, 21]], { 3 => 1, 17 => 1, 21 => 1 }],
        [[[3, 3, 3, 3, 3, 5, 5, 5]], { 3 => 5, 5 => 3 }],
        [[[1, 4, 6], [1, 4, 6]], { 2 => 1, 5 => 2, 7 => 2, 8 => 1, 10 => 2, 12 => 1 }],
        [[[3, 4, 3], [1, 3, 2]], { 4 => 2, 5 => 3, 6 => 3, 7 => 1 }]
      ].freeze

      # Strings for displaying test results.
      RESULT_TEXT = { pass: '✔', fail: '✘ <- failure!', skip: '☂' }.freeze

      # Check all tests defined in {TEST_DATA}.
      #
      # @param calculators [Array<FrequenciesCalculator>]
      # @param report_style [:full, :quiet]
      # @return [Boolean] whether there are no failing tests
      def call(calculators, report_style)
        results = TEST_DATA.to_h { |test| run_test(test, calculators) }
        full_report(results) if report_style == :full
        results.values.none? { |test_result| test_result.values.any? { _1 == :fail } }
      end

      private

      # @param test [Array(Array<Integer, Array<Integer>>, Hash{Integer => Integer})]
      #   pair of a dice list definition and expected results
      # @return [Array(Array<AbstractDie>, Hash{FrequenciesCalculator => :pass, :fail, :skip})]
      #   result of running the test in a format suitable for +#to_h+
      def run_test(test, calculators)
        dice = build_dice(test.first)
        test_result = calculators.each_with_object({}) do |calculator, hash|
          hash[calculator] =
            if calculator.valid_for?(dice)
              calculator.call(dice) == test.last ? :pass : :fail
            else
              :skip
            end
        end
        [dice, test_result]
      end

      # Build a list of {AbstractDie} objects from a plain definition.
      #
      # @param definition [Array<Integer, Array<Integer>>]
      # @return [Array<AbstractDie>]
      def build_dice(definition)
        definition.map { _1.is_a?(Integer) ? RegularDie.new(_1) : AbstractDie.new(_1) }
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

# List of calculators to use, ordered by efficiency.
calculators = [
  Dicey::SumFrequencyCalculators::RegularFrequenciesCalculator.new,
  Dicey::SumFrequencyCalculators::GenericFrequenciesCalculator.new
]
# Formatters which can be used for output.
formatters = {
  'list' => Dicey::OutputFormatters::ListFormatter, 'gnuplot' => Dicey::OutputFormatters::GnuplotFormatter,
  'yaml' => Dicey::OutputFormatters::YAMLFormatter, 'json' => Dicey::OutputFormatters::JSONFormatter
}

# Parse options and stuff.
require 'optparse'

option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: #{Process.argv0} [options] <number of sides> [<number of sides> ...]"
  parser.version = Dicey::VERSION
  parser.on('--test [REPORT_STYLE]', %w[full quiet], 'Check predefined calculation cases and exit.',
            'REPORT_STYLE can be: `full` or `quiet` (no output).', '`full` is default.') do |report_style|
    exit Dicey::SumFrequencyCalculators::TestRunner.new.call(calculators, report_style&.to_sym || :full)
  end
  parser.on('-f', '--format FORMAT', formatters, 'Select output format for results.',
            "FORMAT can be: #{formatters.keys.map { "`#{_1}`" }.join(', ')}.", '`list` is default.')
end
options = { format: Dicey::OutputFormatters::ListFormatter }
arguments = option_parser.parse!(into: options)

# Require libraries only when needed, to cut on run time.
if options[:format] == Dicey::OutputFormatters::YAMLFormatter
  require 'yaml'
elsif options[:format] == Dicey::OutputFormatters::JSONFormatter
  require 'json'
end

# Actually run the calculations!
dice = arguments.map { Dicey::RegularDie.new(_1.to_i) }
frequencies = calculators.find { _1.valid_for?(dice) }.call(dice)

# Format and output the result.
output = options[:format].new.call(frequencies, Dicey::AbstractDie.describe(dice))
puts output
