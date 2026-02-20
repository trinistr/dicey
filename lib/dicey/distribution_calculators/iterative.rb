# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Calculator for a collection of {AbstractDie} which goes through
    # every possible combination of dice (somewhat slow).
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be available.
    class Iterative < BaseCalculator
      include Mixins::VectorizeDice

      private

      def validate(dice)
        !!defined?(VectorNumber) || dice.all?(NumericDie)
      end

      def calculate_heuristic(dice_count, sides_count)
        (157_000 * dice_count**2 + 12_500_000) + (195_000 * sides_count**2 + 257_000_000)
      end

      def calculate(dice, **nil)
        dice = vectorize_dice(dice)

        dice[1..].reduce(dice.first.sides_list.tally) do |previous_distribution, die|
          convolve_with_die(previous_distribution, die.sides_list.tally)
        end
      end

      def convolve_with_die(previous_distribution, die_sides)
        previous_distribution.each_with_object({}) do |(outcome, weight), next_distribution|
          die_sides.each do |side, side_weight|
            next_outcome = outcome + side
            next_distribution[next_outcome] ||= 0
            next_distribution[next_outcome] += weight * side_weight
          end
        end
      end
    end
  end
end
