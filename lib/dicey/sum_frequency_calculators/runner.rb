# frozen_string_literal: true

require_relative "../die_foundry"

require_relative "brute_force"
require_relative "kronecker_substitution"
require_relative "multinomial_coefficients"

module Dicey
  module SumFrequencyCalculators
    # The defaultest runner which calculates roll frequencies from command-line dice.
    class Runner
      # Transform die definitions to roll frequencies.
      #
      # @param arguments [Array<String>] die definitions
      # @param format [#call] formatter for output
      # @param result [Symbol] result type selector
      # @return [nil]
      # @raise [DiceyError]
      def call(arguments, format:, result:, **)
        raise DiceyError, "no dice!" if arguments.empty?

        dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
        calculator = calculator_selector.call(dice)
        raise DiceyError, "no calculator could handle these dice!" unless calculator

        frequencies = calculator.call(dice, result_type: result)

        format.call(frequencies, AbstractDie.describe(dice))
      end

      private

      def die_foundry
        @die_foundry ||= DieFoundry.new
      end

      def calculator_selector
        @calculator_selector ||= AutoSelector.new
      end
    end
  end
end
