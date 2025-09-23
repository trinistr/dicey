# frozen_string_literal: true

require_relative "die_foundry"

require_relative "rational_to_integer"

module Dicey
  # Let the dice roll!
  class Roller
    include RationalToInteger

    # @param arguments [Array<String>] die definitions
    # @param format [#call] formatter for output
    # @return [nil]
    # @raise [DiceyError]
    def call(arguments, format:, **)
      raise DiceyError, "no dice!" if arguments.empty?

      dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
      result = dice.sum(&:roll)

      format.call({ "roll" => rational_to_integer(result) }, AbstractDie.describe(dice))
    end

    private

    def die_foundry
      @die_foundry ||= DieFoundry.new
    end
  end
end
