# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"
require_relative "../mixins/warn_about_vector_number"

module Dicey
  module DistributionCalculators
    # Calculator for a collection of {AbstractDie} which goes through
    # every possible combination of dice, being almost a brute-force
    # approach (very slow).
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
        dice = vectorize_dice(dice) if defined?(VectorNumber)
        dice.map(&:sides_list).reduce { |result, die|
          result.flat_map { |roll| die.map { |side| roll + side } }
        }.tally
      end
    end
  end
end
