# frozen_string_literal: true

require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Distribution calculator with fast paths for some trivial cases (very fast).
    #
    # Currently included cases:
    # - single {AbstractDie} (even without +VectorNumber+),
    # - two of the same {RegularDie}.
    #
    # You probably shouldn't use this one manually, it's only there for {AutoSelector}.
    class Trivial < BaseCalculator
      include Mixins::VectorizeDice

      private

      def validate(dice)
        return true if dice.size == 1
        return true if dice.size == 2 && RegularDie === dice.first && dice.first == dice.last

        false
      end

      def calculate_heuristic(dice_count, sides_count)
        sides_count * dice_count
      end

      def calculate(dice, **nil)
        if dice.size == 1
          # Categorical distribution.
          dice = vectorize_dice(dice) if defined?(VectorNumber)
          dice.first.sides_list.tally
        else
          # Simplest multinomial distribution.
          bimultinomial(dice.first)
        end
      end

      def bimultinomial(die)
        middle = die.sides_num + 1
        (2..(die.sides_num * 2)).each_with_object({}) do |i, hash|
          hash[i] = (middle - 1) - (middle - i).abs
        end
      end
    end
  end
end
