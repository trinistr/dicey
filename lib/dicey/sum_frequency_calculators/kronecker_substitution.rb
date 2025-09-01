# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # Calculator for lists of dice with non-negative integer sides (fast).
    #
    # Example dice: (1,2,3,4), (0,1,5,6), (5,4,5,4,5).
    #
    # Based on Kronecker substitution method for polynomial multiplication.
    # @see https://en.wikipedia.org/wiki/Kronecker_substitution
    # @see https://arxiv.org/pdf/0712.4046v1.pdf in particular section 3
    class KroneckerSubstitution < BaseCalculator
      private

      def validate(dice)
        dice.all? { |die| die.sides_list.all? { _1.is_a?(Integer) && _1 >= 0 } }
      end

      def calculate(dice)
        polynomials = build_polynomials(dice)
        evaluation_point = find_evaluation_point(polynomials)
        values = evaluate_polynomials(polynomials, evaluation_point)
        product = values.reduce(:*)
        extract_coefficients(product, evaluation_point)
      end

      # Turn dice into hashes where keys are side values and values are numbers of those sides,
      # representing corresponding polynomials where
      # side values are powers and numbers are coefficients.
      #
      # @param dice [Enumerable<NumericDie>]
      # @return [Array<Hash{Integer => Integer}>]
      def build_polynomials(dice)
        dice.map { _1.sides_list.tally }
      end

      # Find a power of 2 which is larger in magnitude than any resulting polynomial coefficients,
      # and so able to hold each coefficient without overlap.
      #
      # @param polynomials [Array<Hash{Integer => Integer}>]
      # @return [Integer]
      def find_evaluation_point(polynomials)
        polynomial_length = polynomials.flat_map(&:keys).max + 1
        e = Math.log2(polynomial_length).ceil
        b = polynomials.flat_map(&:values).max.bit_length
        coefficient_magnitude = (polynomials.size * b) + ((polynomials.size - 1) * e)
        1 << coefficient_magnitude
      end

      # Get values of polynomials if +evaluation_point+ is substituted for the variable.
      #
      # @param polynomials [Array<Hash{Integer => Integer}>]
      # @param evaluation_point [Integer]
      # @return [Array<Integer>]
      def evaluate_polynomials(polynomials, evaluation_point)
        polynomials.map do |polynomial|
          polynomial.sum { |power, coefficient| (evaluation_point**power) * coefficient }
        end
      end

      # Unpack coefficients from the product of polynomial values,
      # building resulting polynomial.
      #
      # @param product [Integer]
      # @param evaluation_point [Integer]
      # @return [Hash{Integer => Integer}]
      def extract_coefficients(product, evaluation_point)
        window = evaluation_point - 1
        window_shift = window.bit_length
        (0..).each_with_object({}) do |power, result|
          coefficient = product & window
          result[power] = coefficient unless coefficient.zero?
          product >>= window_shift
          break result if product.zero?
        end
      end
    end
  end
end
