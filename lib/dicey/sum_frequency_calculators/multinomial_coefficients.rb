# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
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
        return false unless first_die.is_a?(NumericDie)
        return false unless dice.all? { _1 == first_die }
        return true if first_die.sides_num == 1

        arithmetic_sequence?(first_die.sides_list)
      end

      # @param sides_list [Array<Numeric>]
      # @return [false, Array<Numeric>]
      def arithmetic_sequence?(sides_list)
        increment = sides_list[1] - sides_list[0]
        return false if increment.zero?

        sides_list.each_cons(2) { return false if _1 + increment != _2 }
      end

      # @param dice [Array<NumericDie>]
      # @return [Hash{Numeric => Integer}]
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
        # Each element is a sum of +m+ elements in the previous row
        # with indices less or equal to its, with out-of-bounds indices corresponding to 0s.
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

      # @param row_index [Integer]
      # @param window_size [Integer]
      # @param previous_row [Array<Integer>]
      # @return [Array<Integer>]
      def next_row_of_coefficients(row_index, window_size, previous_row)
        length = (row_index * window_size) + 1
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
        Enumerator
          .produce(first) { _1 + increment }
          .take_while { (_1 < last) == (first < last) || _1 == last }
      end
    end
  end
end
