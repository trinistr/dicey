# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"
require_relative "../mixins/warn_about_vector_number"

module Dicey
  module DistributionCalculators
    # Calculator for a collection of {AbstractDie} which goes through
    # every possible combination of dice (somewhat slow).
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be installed.
    class Iterative < BaseCalculator
      include Mixins::VectorizeDice
      include Mixins::WarnAboutVectorNumber

      private

      def validate(dice)
        if defined?(VectorNumber) || dice.all?(NumericDie)
          true
        else
          warn_about_vector_number
        end
      end

      def calculate_heuristic(dice_count, sides_count)
        1000 * (sides_count**(1.3 * dice_count).ceil)
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
