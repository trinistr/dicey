# frozen_string_literal: true

require_relative "../mixins/missing_math"
require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Distribution calculator with fast paths for some trivial cases (very fast).
    #
    # Currently included cases:
    # - single {AbstractDie}, even without +VectorNumber+ (categorical distribution),
    # - two of the same {RegularDie} (simple multinomial distribution),
    # - any number of same two-sided {AbstractDie}, like coins (binomial distribution).
    #
    # You probably shouldn't use this one manually, it's mostly there for {AutoSelector}.
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
        sides_count * (dice_count**2)
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

        coefficients = recurrent_combinations(dice_count)
        length = coefficients.size - 1
        first, second = die.sides_list
        coefficients.each_with_index.with_object(Hash.new(0)) do |(coefficient, i), hash|
          hash[(first * (length - i)) + (second * i)] += coefficient
        end
      end

      # Calculating three factorials for each combination is pretty expensive.
      # As the actual formulas just go through factorials in order,
      # we can drastically reduce the complexity by reusing previous values.
      def recurrent_combinations(dice_count)
        count_factorial = factorial(dice_count)
        index_factorial = 1
        reverse_factorial = count_factorial
        combinations = Array.new(dice_count + 1, 1)
        (1..dice_count).each do |i|
          index_factorial *= i
          reverse_factorial /= (dice_count - i + 1)
          combinations[i] = count_factorial / (index_factorial * reverse_factorial)
        end
        combinations
      end
    end
  end
end
