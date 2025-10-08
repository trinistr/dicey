# frozen_string_literal: true

# Try to load "vector_number" pre-emptively.
begin
  require "vector_number"
rescue LoadError
  # VectorNumber not available, sad
end

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # Calculator for a collection of {AbstractDie} using exhaustive search (very slow).
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be installed.
    class BruteForce < BaseCalculator
      private

      def validate(dice)
        if defined?(VectorNumber) || dice.all?(NumericDie)
          true
        else
          warn <<~TEXT
            Dice with non-numeric sides need gem "vector_number" to be present and available.
            If this is intended, please call `require "vector_number"` before using the calculator.
          TEXT
          false
        end
      end

      def calculate(dice, **nil)
        side_lists = dice.map(&:sides_list)
        side_lists = vectorize_sides(side_lists) if defined?(VectorNumber)
        combine_dice_enumerators(side_lists).map(&:sum).tally
      end

      def vectorize_sides(side_lists)
        side_lists.map do |list|
          list.map do |side|
            (Numeric === side) ? side : VectorNumber.new([side])
          end
        end
      end

      if defined?(Enumerator::Product)
        # Get an enumerator which goes through all possible permutations of dice sides.
        #
        # @param side_lists [Enumerable<Enumerable<Any>>]
        # @return [Enumerator<Enumerable<Enumerable<Any>>>]
        def combine_dice_enumerators(side_lists)
          Enumerator::Product.new(*side_lists)
        end
      # :nocov:
      else
        # Get an enumerator which goes through all possible permutations of dice sides.
        #
        # @param side_lists [Enumerable<Enumerable<Any>>]
        # @return [Enumerator<Array<Array<Any>>>]
        def combine_dice_enumerators(side_lists)
          product(side_lists)
        end

        # Simplified implementation of {Enumerator::Product}.
        # Adapted from {https://bugs.ruby-lang.org/issues/18685#note-10}.
        #
        # @param enums [Enumerable<Enumerable<Any>>]
        # @return [Enumerator<Array<Array<Any>>>]
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
