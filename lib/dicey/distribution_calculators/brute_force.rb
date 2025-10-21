# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Calculator for a collection of {AbstractDie} using exhaustive search (very slow).
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be installed.
    class BruteForce < BaseCalculator
      include Mixins::VectorizeDice

      private

      def validate(dice)
        if defined?(VectorNumber) || dice.all?(NumericDie)
          true
        else
          warn <<~TEXT
            Dice with non-numeric sides need gem "vector_number" to be present and available.
            If this is intended, please install the gem.
          TEXT
          false
        end
      end

      def calculate_heuristic(dice_count, sides_count)
        1000 * (sides_count**dice_count)
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
