# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"
require_relative "../mixins/warn_about_vector_number"

module Dicey
  module DistributionCalculators
    # "Calculator" for a collection of {AbstractDie} using empirically-obtained statistics.
    #
    # @note This calculator is mostly a joke. It can be useful for educational purposes,
    #   or to verify results of {BruteForce} when in doubt. It is not used automatically.
    #
    # Does a number of rolls and calculates approximate probabilities from that.
    # Even if weights are requested, results are non-integer.
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be installed.
    #
    # *Options:*
    # - *rolls* (Integer) (_defaults_ _to:_ _N_) — number of rolls to perform
    class Empirical < BaseCalculator
      include Mixins::VectorizeDice
      include Mixins::WarnAboutVectorNumber

      # Default number of rolls to perform.
      N = 10_000

      private

      def validate(dice)
        if defined?(VectorNumber) || dice.all?(NumericDie)
          true
        else
          warn_about_vector_number
          false
        end
      end

      def calculate_heuristic(dice_count, sides_count)
        N * dice_count * Math.log2(sides_count)
      end

      def calculate(dice, rolls: N)
        dice = vectorize_dice(dice) if defined?(VectorNumber)
        statistics = rolls.times.with_object(Hash.new(0)) { |_, hash| hash[dice.sum(&:roll)] += 1 }
        total_results = dice.map(&:sides_num).reduce(:*)
        statistics.transform_values { Rational(_1 * total_results, rolls) }
      end

      def verify_result(*)
        # Ignore verification, as this is inherently imprecise.
        true
      end
    end
  end
end
