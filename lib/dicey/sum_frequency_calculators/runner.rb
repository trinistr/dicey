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
      # @param roll_calculators [Array<BaseCalculator>] list of calculators to use
      # @param format [#call] formatter for output
      # @param result [Symbol] result type selector
      # @return [nil]
      # @raise [DiceyError]
      def call(arguments, roll_calculators:, format:, result:, **)
        raise DiceyError, "no dice!" if arguments.empty?

        dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
        frequencies = roll_calculators.find { _1.valid_for?(dice) }&.call(dice, result_type: result)
        raise DiceyError, "no calculator could handle these dice!" unless frequencies

        format.call(frequencies, AbstractDie.describe(dice))
      end

      private

      def die_foundry
        @die_foundry ||= DieFoundry.new
      end
    end
  end
end
