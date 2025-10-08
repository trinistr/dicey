# frozen_string_literal: true

require_relative "die_foundry"

require_relative "mixins/rational_to_integer"
require_relative "mixins/vectorize_dice"

module Dicey
  # Let the dice roll!
  class Roller
    include Mixins::RationalToInteger
    include Mixins::VectorizeDice

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
