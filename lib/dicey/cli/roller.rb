# frozen_string_literal: true

require_relative "../die_foundry"

require_relative "../mixins/rational_to_integer"
require_relative "../mixins/vectorize_dice"

module Dicey
  module CLI
    # Let the dice roll!
    #
    # This is the implementation of roll mode for the CLI.
    class Roller
      include Mixins::RationalToInteger
      include Mixins::VectorizeDice

      # @param arguments [Array<String>] die definitions
      # @param format [#call] formatter for output
      # @return [String]
      # @raise [DiceyError]
      def call(arguments, format:, **)
        raise DiceyError, "no dice!" if arguments.empty?

        dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
        result = roll_dice(dice)

        format.call({ "roll" => rational_to_integer(result) }, AbstractDie.describe(dice))
      rescue TypeError
        raise DiceyError, "can not roll dice with non-numeric sides!"
      end

      private

      def die_foundry
        @die_foundry ||= DieFoundry.new
      end

      def roll_dice(dice)
        dice = vectorize_dice(dice)
        dice.sum(&:roll)
      end
    end
  end
end
