# frozen_string_literal: true

require_relative "../die_foundry"

Dir["../distribution_calculators/*.rb", base: __dir__].each { require_relative _1 }

module Dicey
  module CLI
    # The defaultest runner which calculates roll distribution from command-line dice.
    class CalculatorRunner
      # Transform die definitions to roll distribution.
      #
      # @param arguments [Array<String>] die definitions
      # @param format [#call] formatter for output
      # @param result [Symbol] result type selector
      # @param verbose_printer [VerbosePrinter]
      # @return [String]
      # @raise [DiceyError]
      def call(arguments, format:, result:, verbose_printer: nil, **)
        raise DiceyError, "no dice!" if arguments.empty?

        dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
        calculator = DistributionCalculators::AutoSelector.call(dice)
        raise DiceyError, "no calculator could handle these dice!" unless calculator

        verbose_printer&.print("Using calculator: #{calculator.class}")
        distribution = calculator.call(dice, result_type: result)

        format.call(distribution, AbstractDie.describe(dice))
      end

      private

      def die_foundry
        @die_foundry ||= DieFoundry.new
      end
    end
  end
end
