# frozen_string_literal: true

require_relative "../mixins/missing_math"
require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Distribution calculator with fast paths for some trivial cases (very fast).
    #
    # Currently included cases:
    # - single {AbstractDie} (even without +VectorNumber+),
    # - two of the same {RegularDie},
    # - any number of same two-sided {AbstractDie} (like coins).
    #
    # You probably shouldn't use this one manually, it's only there for {AutoSelector}.
    class Trivial < BaseCalculator
      include Mixins::MissingMath
      include Mixins::VectorizeDice

      private

      def validate(dice)
        dice.size == 1 || two_regular_dice?(dice) || dice_with_two_sides?(dice)
      end

      def two_regular_dice?(dice)
        dice.size == 2 && RegularDie === dice.first && dice.first == dice.last
      end

      def dice_with_two_sides?(dice)
        return false unless dice.first.sides_num == 2 && dice.all? { _1 == dice.first }

        NumericDie === dice.first || defined?(VectorNumber)
      end

      def calculate_heuristic(dice_count, sides_count)
        sides_count * dice_count
      end

      def calculate(dice, **nil)
        die = dice.first
        if dice.size == 1
          categorical(die)
        elsif dice.size == 2 && RegularDie === die
          bimultinomial(die)
        else
          binomial(die, dice.size)
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

      def binomial(die, dice_count)
        die = vectorize_dice(die)

        coefficients = (0..dice_count).map { combinations(dice_count, _1) }
        length = coefficients.size - 1
        first, second = die.sides_list
        coefficients.each_with_index.with_object(Hash.new(0)) do |(coefficient, i), hash|
          hash[(first * (length - i)) + (second * i)] += coefficient
        end
      end
    end
  end
end
