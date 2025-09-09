# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # Calculator for a collection of {NumericDie} using exhaustive search (very slow).
    class BruteForce < BaseCalculator
      private

      def validate(dice)
        dice.all?(NumericDie)
      end

      def calculate(dice)
        combine_dice_enumerators(dice).map(&:sum).tally
      end

      if defined?(Enumerator::Product)
        # Get an enumerator which goes through all possible permutations of dice sides.
        #
        # @param dice [Enumerable<NumericDie>]
        # @return [Enumerator<Array<Numeric>>]
        def combine_dice_enumerators(dice)
          Enumerator::Product.new(*dice.map(&:sides_list))
        end
      # :nocov:
      else
        # Get an enumerator which goes through all possible permutations of dice sides.
        #
        # @param dice [Enumerable<NumericDie>]
        # @return [Enumerator<Array<Numeric>>]
        def combine_dice_enumerators(dice)
          product(dice.map(&:sides_list))
        end

        # Simplified implementation of {Enumerator::Product}.
        # Adapted from {https://bugs.ruby-lang.org/issues/18685#note-10}.
        #
        # @param enums [Enumerable<Enumerable<Numeric>>]
        # @return [Enumerator<Array<Numeric>>]
        def product(enums, &block)
          return to_enum(__method__, enums) unless block_given?

          enums
            .reverse
            .reduce(block) { |inner, enum|
              ->(values) { enum.each_entry { inner.call([*values, _1]) } }
            }
            .call([])
        end
      end
      # :nocov:
    end
  end
end
