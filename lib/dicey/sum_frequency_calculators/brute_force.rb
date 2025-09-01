# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # Calculator for a collection of {NumericDie} using exhaustive search (very slow).
    class BruteForce < BaseCalculator
      private

      # def validate(dice)
      #   dice.all? { |die| die.is_a?(NumericDie) }
      # end

      def calculate(dice)
        # TODO: Replace `combine_dice_enumerators` with `Enumerator.product`.
        combine_dice_enumerators(dice).map(&:sum).tally
      end

      # Get an enumerator which goes through all possible permutations of dice sides.
      #
      # @param dice [Enumerable<NumericDie>]
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
      #
      # @param dice [Enumerable<NumericDie>]
      # @param remaining_iterations [Array<Integer>]
      # @param current_values [Array<Numeric>]
      # @return [void]
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
  end
end
