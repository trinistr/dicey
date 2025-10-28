# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Distribution calculator with fast paths for some trivial cases (very fast).
    #
    # Currently included cases:
    # - single {AbstractDie}, even without +VectorNumber+ (categorical distribution),
    # - two of the same {RegularDie} (simple multinomial distribution).
    #
    # You probably shouldn't use this one manually, it's mostly there for {AutoSelector}.
    class Trivial < BaseCalculator
      include Mixins::VectorizeDice

      private

      def validate(dice)
        dice.size == 1 || two_regular_dice?(dice)
      end

      def two_regular_dice?(dice)
        dice.size == 2 && RegularDie === dice.first && dice.first == dice.last
      end

      def calculate_heuristic(_dice_count, sides_count)
        -5_000_000 + (328 * sides_count - 89800)
      end

      def calculate(dice, **nil)
        die = dice.first
        if dice.size == 1
          categorical(die)
        else
          bimultinomial(die)
        end
      end

      def categorical(die)
        die = vectorize_dice(die)
        die.sides_list.tally
      end

      # Simplest multinomial distribution: two regular dice.
      def bimultinomial(die)
        middle = die.sides_num
        (1...(die.sides_num * 2)).each_with_object({}) do |i, hash|
          hash[i + 1] = middle - (middle - i).abs
        end
      end
    end
  end
end
