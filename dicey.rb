#!/usr/bin/env ruby
# frozen_string_literal: true

# A little program to calculate frequencies (tallies) of each possible result
# for a throw of a given collection of dice, drawing result with `gnuplot`.
# Using dice with exactly equal number of sides is significantly faster.

# Usage: dicey.rb 4 4 4 # calculate frequencies for three 4-sided dice
# Usage: dicey.rb 3 6 # calculate frequencies for a pair of 3-sided and 6-sided dice
# Usage: dicey.rb 1,3,5,7 2,4,6,8 # calculate frequencies for a pair of odd and even 4-sided dice

# A library for rolling dice and calculating roll frequencies.
module Dicey
  VERSION = '0.10.1'

  # General error for Dicey.
  class DiceyError < StandardError; end

  # Asbtract die which may have an arbitrary list of sides,
  # not even neccessarily numbers (but preferably so).
  class AbstractDie
    attr_reader :sides_list, :sides_num, :enum

    @random = Random.new

    # Get a random value using a private instance of Random.
    # @see Random#rand
    def self.rand(...)
      @random.rand(...)
    end

    # Reset internal randomizer using a new seed.
    # @see Random.new
    def self.srand(...)
      @random = Random.new(...)
    end

    # Get a text representation of a list of dice.
    #
    # @param dice [Enumerable<AbstractDie>]
    # @return [String]
    def self.describe(dice)
      dice.join(';')
    end

    # @param sides_list [Enumerable<Object>]
    # @raise [DiceyError] if sides_list is empty
    def initialize(sides_list)
      @sides_list = sides_list.is_a?(Array) ? sides_list.dup.freeze : sides_list.to_a.freeze
      raise DiceyError, 'dice must have at least one side!' if @sides_list.empty?

      @sides_num = @sides_list.size

      sides_enum = @sides_list.to_enum
      @enum = Enumerator.produce do
        sides_enum.next
      rescue StopIteration
        sides_enum.rewind
        retry
      end
    end

    # Get current side of the die.
    # @return [Object] current side
    def current
      @enum.peek
    end

    # Get next side of the die, advancing internal enumerator state.
    # Wraps from last to first side.
    # @return [Object] next side
    def next
      @enum.next
    end

    # Advance internal enumerator state by a random number using {#next}.
    # @return [Object] rolled side
    def roll
      self.class.rand(0...sides_num).times { self.next }
      current
    end

    def to_s
      "(#{sides_list.join(',')})"
    end

    # Determine if this die and the other one have the same list of sides.
    # Be aware that differently ordered sides are not considered equal.
    #
    # @param other [AbstractDie, Object]
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(AbstractDie)

      sides_list == other.sides_list
    end
  end

  # Regular die, which has N sides with numbers from 1 to N.
  class RegularDie < AbstractDie
    D6 = '⚀⚁⚂⚃⚄⚅'

    # Create a list of regular dice with the same number of sides.
    #
    # @param dice [Integer]
    # @param sides [Integer]
    # @return [Array<RegularDie>]
    def self.create_dice(dice, sides)
      (1..dice).map { new(sides) }
    end

    # @param sides [Integer]
    def initialize(sides)
      super((1..sides))
    end

    def to_s
      sides_num <= D6.size ? D6[sides_num - 1] : "[#{sides_num}]"
    end
  end

  # Helper class to define die definitions and automatically select the best one.
  class DieFoundry
    MOLDS = {
      # Positive integer goes into the RegularDie mold.
      ->(d) { /\A[1-9]\d*\z/.match?(d) } => :regular_mold,
      # List of numbers goes into the AbstractDie mold.
      ->(d) { /\A\(?-?\d++(?:,-?\d++)*\)?\z/.match?(d) } => :weirdly_shaped_mold,
      # Real numbers require arbitrary precision arithmetic, which is not enabled by default.
      ->(d) { /\A\(?-?\d++(?:\.\d++)?(?:,-?\d++(?:\.\d++)?)*+\)?\z/.match?(d) } => :weirdly_precise_mold,
      # Anything else is spilled on the floor.
      ->(*) { true } => :broken_mold
    }.freeze

    BRACKET_STRIPPER = /\A\(?(.+)\)?\z/.freeze

    # Cast a die definition into a mold to make a die.
    #
    # @param definition [String] die shape, refer to {MOLDS} for possible variants
    # @return [AbstractDie, RegularDie]
    # @raise [DiceyError] if no mold fits the definition
    def cast(definition)
      _shape, mold = MOLDS.find { |shape, _mold| shape.call(definition) }
      send(mold, definition)
    end

    private

    def regular_mold(definition)
      RegularDie.new(definition.to_i)
    end

    def weirdly_shaped_mold(definition)
      definition = definition.match(BRACKET_STRIPPER)[1]
      AbstractDie.new(definition.split(',').map(&:to_i))
    end

    def weirdly_precise_mold(definition)
      require 'bigdecimal'
      definition = definition.match(BRACKET_STRIPPER)[1]
      AbstractDie.new(definition.split(',').map { BigDecimal(_1) })
    end

    def broken_mold(definition)
      raise DiceyError, "can not cast die from `#{definition}`!"
    end
  end
end

module Dicey
  module SumFrequencyCalculators
    # Base frequencies calculator.
    # @abstract
    class BaseCalculator
      RESULT_TYPES = %i[frequencies probabilities].freeze

      # @param dice [Enumerable<AbstractDie>]
      # @param result [:frequencies, :probabilities]
      # @return [Hash{Numeric => Numeric}] frequencies of each sum
      # @raise [DiceyError] if dice list is invalid for the calculator
      # @raise [DiceyError] if `result` is invalid
      # @raise [DiceyError] if calculator returned obviously wrong results
      def call(dice, result: :frequencies)
        raise DiceyError, "#{result} is not a valid result type!" unless RESULT_TYPES.include?(result)
        raise DiceyError, "#{self.class} can not handle these dice!" unless valid_for?(dice)

        frequencies = calculate(dice).sort.to_h
        verify_result(frequencies, dice)
        transform_result(frequencies, result)
      end

      # Whether this calculator can be used for the list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
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

      # Check that resulting frequencies actually add up to what they are supposed to be.
      #
      # @param frequencies [Hash{Numeric => Integer}]
      # @param dice [Enumerable<AbstractDie>]
      # @return [void]
      # @raise [DiceyError] if result is wrong
      def verify_result(frequencies, dice)
        valid = frequencies.values.sum == dice.map(&:sides_num).reduce(:*)
        raise DiceyError, "calculator #{self.class} returned invalid results!" unless valid
      end

      # Transform calculated frequencies to requested result_type, if needed.
      #
      # @param frequencies [Hash{Numeric => Integer}]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @return [Hash{Numeric => Numeric}]
      def transform_result(frequencies, result_type)
        case result_type
        when :frequencies
          frequencies
        when :probabilities
          total = frequencies.values.sum
          frequencies.transform_values { _1.fdiv(total) }
        end
      end
    end

    # Calculator for a collection of dice using complete iteration (very slow).
    #
    # Able to handle {AbstractDie} lists with arbitrary numeric sides.
    class CompleteIteration < BaseCalculator
      private

      def validate(dice)
        dice.all? { |die| die.sides_list.all? { _1.is_a?(Numeric) } }
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

    # Calculator for lists of dice with non-negative integer sides (fast).
    #
    # Example dice: (1,2,3,4), (0,1,5,6), (5,4,5,4,5).
    #
    # Based on Kronecker substitution method for polynomial multiplication.
    # @see https://en.wikipedia.org/wiki/Kronecker_substitution
    # @see https://arxiv.org/pdf/0712.4046v1.pdf in particular section 3
    class KroneckerSubstitution < BaseCalculator
      private

      def validate(dice)
        dice.all? { |die| die.sides_list.all? { _1.is_a?(Integer) && _1 >= 0 } }
      end

      def calculate(dice)
        polynomials = build_polynomials(dice)
        evaluation_point = find_evaluation_point(polynomials)
        values = evaluate_polynomials(polynomials, evaluation_point)
        product = values.reduce(:*)
        extract_coefficients(product, evaluation_point)
      end

      # Turn dice into hashes where keys are side values and values are numbers of those sides,
      # representing corresponding polynomials where side values are powers and numbers are coefficients.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Array<Hash{Integer => Integer}>]
      def build_polynomials(dice)
        dice.map { _1.sides_list.tally }
      end

      # Find a power of 2 which is larger in magnitude than any resulting polynomial coefficients,
      # and so able to hold each coefficient without overlap.
      #
      # @param polynomials [Array<Hash{Integer => Integer}>]
      # @return [Integer]
      def find_evaluation_point(polynomials)
        polynomial_length = polynomials.flat_map(&:keys).max + 1
        e = Math.log2(polynomial_length).ceil
        b = polynomials.flat_map(&:values).max.bit_length
        coefficient_magnitude = polynomials.size * b + (polynomials.size - 1) * e
        1 << coefficient_magnitude
      end

      # Get values of polynomials if `evaluation_point` is substituted for the variable.
      #
      # @param polynomials [Array<Hash{Integer => Integer}>]
      # @param evaluation_point [Integer]
      # @return [Array<Integer>]
      def evaluate_polynomials(polynomials, evaluation_point)
        polynomials.map do |polynomial|
          polynomial.sum { |power, coefficient| evaluation_point**power * coefficient }
        end
      end

      # Unpack coefficients from the product of polynomial values,
      # building resulting polynomial.
      #
      # @param product [Integer]
      # @param evaluation_point [Integer]
      # @return [Hash{Integer => Integer}]
      def extract_coefficients(product, evaluation_point)
        window = evaluation_point - 1
        window_shift = window.bit_length
        (0..).each_with_object({}) do |power, result|
          coefficient = product & window
          result[power] = coefficient unless coefficient.zero?
          product >>= window_shift
          break result if product.zero?
        end
      end
    end

    # Calculator for multiple equal dice with sides forming an arithmetic sequence (fast).
    #
    # Example dice: (1,2,3,4), (-2,-1,0,1,2), (0,0.2,0.4,0.6), (-1,-2,-3).
    #
    # Based on extension of Pascal's triangle for a higher number of coefficients.
    # @see https://en.wikipedia.org/wiki/Pascal%27s_triangle
    # @see https://en.wikipedia.org/wiki/Trinomial_triangle
    class MultinomialCoefficients < BaseCalculator
      private

      def validate(dice)
        first_die = dice.first
        return false unless first_die.sides_list.all? { _1.is_a?(Numeric) }
        return false unless dice.all? { _1 == first_die }
        return true if first_die.sides_num == 1

        check_for_arithemetic_sequence(first_die.sides_list)
      end

      def check_for_arithemetic_sequence(sides_list)
        increment = sides_list[1] - sides_list[0]
        return false if increment.zero?

        sides_list.each_cons(2) { return false if _1 + increment != _2 }
      end

      def calculate(dice)
        first_die = dice.first
        number_of_sides = first_die.sides_num
        number_of_dice = dice.size

        frequencies = multinomial_coefficients(number_of_dice, number_of_sides)
        result_sums_list(first_die.sides_list, number_of_dice).zip(frequencies).to_h
      end

      # Calculate coefficients for a multinomial of the form
      # <tt>(x^1 +...+ x^m)^n</tt>, where +m+ is the number of sides and +n+ is the number of dice.
      #
      # @param dice [Integer] number of dice, must be positive
      # @param sides [Integer] number of sides, must be positive
      # @param throw_away_garbage [Boolean] whether to discard unused coefficients (debug option)
      # @return [Array<Integer>]
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

      # Get sequence of sums which correspond to calculated frequencies.
      #
      # @param sides_list [Enumerable<Numeric>]
      # @param number_of_dice [Integer]
      # @return [Array<Numeric>]
      def result_sums_list(sides_list, number_of_dice)
        first = number_of_dice * sides_list.first
        last = number_of_dice * sides_list.last
        return [first] if first == last

        increment = sides_list[1] - sides_list[0]
        # require "debug"; binding.break
        Enumerator.produce(first) { _1 + increment }.take_while { (_1 < last) == (first < last) || _1 == last }
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
        initial_string = description ? +"# #{description}\n" : String.new
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
        [[[-0.25, 0.0, 0.25, 0.5, 0.75], [-0.25, 0.0, 0.25, 0.5, 0.75], [-0.25, 0.0, 0.25, 0.5, 0.75]],
         { -0.75 => 1, -0.5 => 3, -0.25 => 6, 0.0 => 10, 0.25 => 15, 0.5 => 18, 0.75 => 19,
           1.0 => 18, 1.25 => 15, 1.5 => 10, 1.75 => 6, 2.0 => 3, 2.25 => 1 }]
      ].freeze

      # Strings for displaying test results.
      RESULT_TEXT = { pass: '✔', fail: '✘ 🠐 failure!', skip: '☂', crash: '⛐ 🠐 crash!' }.freeze
      FAILURE_RESULTS = %i[fail crash].freeze

      # Check all tests defined in {TEST_DATA}.
      #
      # @param calculators [Array<BaseCalculator>]
      # @param report_style [:full, :quiet]
      # @return [Boolean] whether there are no failing tests
      def call(calculators, report_style)
        results = TEST_DATA.to_h { |test| run_test(test, calculators) }
        full_report(results) if report_style == :full
        results.values.none? { |test_result| test_result.values.any? { FAILURE_RESULTS.include?(_1) } }
      end

      private

      # @param test [Array(Array<Integer, Array<Numeric>>, Hash{Numeric => Integer})]
      #   pair of a dice list definition and expected results
      # @return [Array(Array<AbstractDie>, Hash{BaseCalculator => :pass, :fail, :skip, :crash})]
      #   result of running the test in a format suitable for +#to_h+
      def run_test(test, calculators)
        dice = build_dice(test.first)
        test_result = calculators.each_with_object({}) do |calculator, hash|
          hash[calculator] = run_test_on_calculator(calculator, dice, test.last)
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

      # Determine test result for the selected calculator.
      def run_test_on_calculator(calculator, dice, expectation)
        return :skip unless calculator.valid_for?(dice)

        calculator.call(dice) == expectation ? :pass : :fail
      rescue StandardError
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

# List of calculators to use, ordered by efficiency.
calculators = [
  Dicey::SumFrequencyCalculators::MultinomialCoefficients.new,
  Dicey::SumFrequencyCalculators::KroneckerSubstitution.new,
  Dicey::SumFrequencyCalculators::CompleteIteration.new
]
# Allowed result types.
result_types = Dicey::SumFrequencyCalculators::BaseCalculator::RESULT_TYPES.to_h { [_1.to_s, _1.to_sym] }
# Formatters which can be used for output.
formatters = {
  'list' => Dicey::OutputFormatters::ListFormatter, 'gnuplot' => Dicey::OutputFormatters::GnuplotFormatter,
  'yaml' => Dicey::OutputFormatters::YAMLFormatter, 'json' => Dicey::OutputFormatters::JSONFormatter
}

# Parse options and stuff.
require 'optparse'
option_parser = OptionParser.new do |parser|
  parser.banner = <<~TEXT
    Usage: #{parser.program_name} [options] <number of sides> [<number of sides> ...]
           #{parser.program_name} --test [full|quiet]
    All option names and arguments can be abbreviated if abbreviation is unambigious.
  TEXT
  parser.version = Dicey::VERSION
  parser.on('-r', '--result TYPE', result_types,
            'Select result type for output.',
            "TYPE can be: #{result_types.keys.map { "`#{_1}`" }.join(', ')}.", '`frequencies` is default.')
  parser.on('-f', '--format FORMAT', formatters,
            'Select output format for results.',
            "FORMAT can be: #{formatters.keys.map { "`#{_1}`" }.join(', ')}.", '`list` is default.')
  parser.on('--test [REPORT_STYLE]', %w[full quiet],
            'Check predefined calculation cases and exit.',
            'REPORT_STYLE can be: `full` or `quiet`.', '`full` is default.') do |report_style|
    exit Dicey::SumFrequencyCalculators::TestRunner.new.call(calculators, report_style&.to_sym || :full)
  end
  parser.on_tail('-h', '--help', 'Show this help and exit.') do
    puts parser.help
    exit
  end
  parser.on_tail('-v', '--version', 'Show program version and exit.') do
    puts parser.ver
    exit
  end
end
options = { format: Dicey::OutputFormatters::ListFormatter, result: :frequencies }
arguments = option_parser.parse!(into: options)
raise Dicey::DiceyError, 'no dice!' if arguments.empty?

# Require libraries only when needed, to cut on run time.
if options[:format] == Dicey::OutputFormatters::YAMLFormatter
  require 'yaml'
elsif options[:format] == Dicey::OutputFormatters::JSONFormatter
  require 'json'
end

# Make dice from the provided definitions.
foundry = Dicey::DieFoundry.new
dice = arguments.map { |definition| foundry.cast(definition) }

# Actually run the calculations!
frequencies = calculators.find { _1.valid_for?(dice) }&.call(dice, result: options[:result])
raise Dicey::DiceyError, 'no calculator could handle these dice!' unless frequencies

# Format and output the result.
output = options[:format].new.call(frequencies, Dicey::AbstractDie.describe(dice))
puts output
