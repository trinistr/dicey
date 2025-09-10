# frozen_string_literal: true

module Dicey
  # Asbtract die which may have an arbitrary list of sides,
  # not even neccessarily numbers (but preferably so).
  class AbstractDie
    # rubocop:disable Style/ClassVars

    # @api private
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
    # @param dice [Enumerable<AbstractDie>, AbstractDie]
    # @return [String]
    def self.describe(dice)
      return dice.to_s if AbstractDie === dice
      return dice.join(";") if Array === dice

      dice.to_a.join(";")
    end

    # Create a bunch of different dice at once.
    #
    # @param definitions [Array<Enumerable<Any>>, Array<Any>]
    #   list of definitions suitable for the dice class
    # @return [Array<AbstractDie>]
    def self.from_list(*definitions)
      definitions.map { new(_1) }
    end

    # Create a number of equal dice.
    #
    # @param count [Integer] number of dice to create
    # @param definition [Enumerable<Any>, Any]
    #   definition suitable for the dice class
    # @return [Array<AbstractDie>]
    def self.from_count(count, definition)
      Array.new(count) { new(definition) }
    end

    attr_reader :sides_list, :sides_num

    # @param sides_list [Enumerable<Any>]
    # @raise [DiceyError] if +sides_list+ is empty
    def initialize(sides_list)
      @sides_list = (Array === sides_list) ? sides_list.dup.freeze : sides_list.to_a.freeze
      raise DiceyError, "dice must have at least one side!" if @sides_list.empty?

      @sides_num = @sides_list.size
      @current_side_index = 0
    end

    # Get current side of the die.
    #
    # @return [Any] current side
    def current
      @sides_list[@current_side_index]
    end

    # Get next side of the die, advancing internal state.
    # Starts from first side, wraps from last to first side.
    #
    # @return [Any] next side
    def next
      ret = current
      @current_side_index = (@current_side_index + 1) % @sides_num
      ret
    end

    # Move internal state to a random side.
    #
    # @return [Any] rolled side
    def roll
      @current_side_index = self.class.rand(0...@sides_num)
      current
    end

    # @return [String]
    def to_s
      "(#{@sides_list.join(",")})"
    end

    # Determine if this die and the other one have the same list of sides.
    # Be aware that differently ordered sides are not considered equal.
    #
    # @param other [AbstractDie, Any]
    # @return [Boolean]
    def ==(other)
      AbstractDie === other && same_sides?(other)
    end

    # Determine if this die and the other one are of the same class
    # and have the same list of sides.
    # Be aware that differently ordered sides are not considered equal.
    #
    # +die_1.eql?(die_2)+ implies +die_1.hash == die_2.hash+.
    #
    # @param other [AbstractDie, Any]
    # @return [Boolean]
    def eql?(other)
      self.class === other && same_sides?(other)
    end

    # Generates an Integer hash value for this object.
    #
    # @return [Integer]
    def hash
      [self.class, @sides_list].hash
    end

    private

    # @param other [AbstractDie]
    # @return [Boolean]
    def same_sides?(other)
      @sides_list == other.sides_list
    end
  end
end
