# frozen_string_literal: true

require_relative "die_foundry"

module Dicey
  # Let the dice roll!
  class Roller
    # @param arguments [Array<String>] die definitions
    # @param format [#call] formatter for output
    # @return [nil]
    # @raise [DiceyError]
    def call(arguments, format:, **)
      raise DiceyError, "no dice!" if arguments.empty?

      dice = arguments.flat_map { |definition| die_foundry.cast(definition) }
      result = dice.sum(&:roll)

      format.call({ "roll" => result }, AbstractDie.describe(dice))
    end

    private

    def die_foundry
      @die_foundry ||= DieFoundry.new
    end
  end
end
