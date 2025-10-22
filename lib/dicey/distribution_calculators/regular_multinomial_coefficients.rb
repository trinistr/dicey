# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module DistributionCalculators
    # Calculator for multiple equal regular dice (fast).
    #
    # Example dice: D6, D4, etc.
    #
    # Rolling multiple of the same dice is the same thing as rolling a single die
    # multiple times and summing the results.
    # This arrangement corresponds to a multinomial distribution.
    #
    # The usual way to calculate probabilities for such distribution involves
    # way too many factorials of large numbers for comfort.
    # (`Math.gamma` doesn't even handle large enough numbers, and produces Floats anyway).
    # Instead, we use a Pascal's triangle extension for a higher number of coefficients.
    # This calculator uses a simplified algorithm for regular dice.
    #
    # @see https://en.wikipedia.org/wiki/Multinomial_distribution
    # @see https://en.wikipedia.org/wiki/Pascal's_triangle
    # @see https://en.wikipedia.org/wiki/Trinomial_triangle
    class RegularMultinomialCoefficients < BaseCalculator
      private

      def validate(dice)
        first_die = dice.first
        first_die.is_a?(RegularDie) && dice.all? { _1.eql?(first_die) }
      end

      def calculate_heuristic(dice_count, sides_count)
        100 * (dice_count**2.2) * 500 * (sides_count**1.9)
      end

      def calculate(dice, **nil)
        dice_count = dice.size
        sides_count = dice.first.sides_num

        weights = multinomial_coefficients(dice_count, sides_count)
        outcomes_list(dice_count, sides_count).zip(weights).to_h
      end

      # Calculate coefficients for a multinomial of the form
      # <tt>(x^1 +...+ x^m)^n</tt>, where +m+ is the number of sides and +n+ is the number of dice.
      #
      # @param dice_count [Integer] number of dice, must be positive
      # @param sides_count [Integer] number of sides, must be positive
      # @return [Array<Integer>]
      def multinomial_coefficients(dice_count, sides_count)
        # This builds a triangular matrix where first elements are always 1s
        # and other elements are sums of +sides+ elements in the previous row
        # with indices less or equal, with out-of-bounds indices corresponding to 0s.
        # Example for sides=3:
        # 1
        # 1 1 1
        # 1 2 3 2 1
        # 1 3 6 7 6 3 1, etc.
        # We start directly from second row, which corresponds to 1 die.
        coefficients = Array.new(sides_count, 1)
        (2..dice_count).each do |row_index|
          coefficients = next_row_of_coefficients(row_index, sides_count - 1, coefficients)
        end
        coefficients
      end

      # @param row_index [Integer]
      # @param window_size [Integer]
      # @param previous_row [Array<Integer>]
      # @return [Array<Integer>]
      def next_row_of_coefficients(row_index, window_size, previous_row)
        length = (row_index * window_size) + 1
        (0...length).map do |col_index|
          # Have to clamp to 0 to prevent accessing array from the end.
          # TruffleRuby can't handle endless range in #clamp (see https://github.com/oracle/truffleruby/issues/3945).
          window_range = ((col_index - window_size).clamp(0..col_index)..col_index)
          window_range.sum { |i| previous_row.fetch(i, 0) }
        end
      end

      # Get sequence of outcomes which correspond to calculated weights.
      #
      # @param dice_count [Integer]
      # @param sides_count [Integer]
      # @return [Array<Numeric>]
      def outcomes_list(dice_count, sides_count)
        (dice_count..(dice_count * sides_count)).to_a
      end
    end
  end
end
