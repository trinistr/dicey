# frozen_string_literal: true

module Dicey
  # Asbtract die which may have an arbitrary list of sides,
  # not even neccessarily numbers (but preferably so).
  class AbstractDie
    # rubocop:disable Style/ClassVars

    # Get a random value using a private instance of Random.
    # @see Random#rand
    def self.rand(...)
      @@random.rand(...)
    end

    # Reset internal randomizer using a new seed.
    # @see Random.new
    def self.srand(...)
      @@random = Random.new(...)
    end

    # Yes, class variable is actually useful here.
    # TODO: Allow supplying a custom Random.
    @@random = Random.new

    # rubocop:enable Style/ClassVars

    # Get a text representation of a list of dice.
    #
    # @param dice [Enumerable<AbstractDie>]
    # @return [String]
    def self.describe(dice)
      dice.join(";")
    end

    attr_reader :sides_list, :sides_num

    # @param sides_list [Enumerable<Object>]
    # @raise [DiceyError] if +sides_list+ is empty
    def initialize(sides_list)
      @sides_list = sides_list.is_a?(Array) ? sides_list.dup.freeze : sides_list.to_a.freeze
      raise DiceyError, "dice must have at least one side!" if @sides_list.empty?

      @sides_num = @sides_list.size

      sides_enum = @sides_list.to_enum
      @enum =
        Enumerator.produce do
          sides_enum.next
        rescue StopIteration
          sides_enum.rewind
          retry
        end
    end

    # Get current side of the die.
    # @return [Object] current side
    def current
      @enum.peek
    end

    # Get next side of the die, advancing internal enumerator state.
    # Wraps from last to first side.
    # @return [Object] next side
    def next
      @enum.next
    end

    # Advance internal enumerator state by a random number using {#next}.
    # @return [Object] rolled side
    def roll
      self.class.rand(0...sides_num).times { self.next }
      current
    end

    # @return [String]
    def to_s
      "(#{sides_list.join(",")})"
    end

    # Determine if this die and the other one have the same list of sides.
    # Be aware that differently ordered sides are not considered equal.
    #
    # @param other [AbstractDie, Object]
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(AbstractDie)

      sides_list == other.sides_list
    end
  end
end
