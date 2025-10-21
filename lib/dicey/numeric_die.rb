# frozen_string_literal: true

require_relative "abstract_die"

module Dicey
  # A die which only has numeric sides, with no shenanigans.
  #
  # The only inherent difference in behavior compared to {AbstractDie} is
  # that this class checks values for sides on initialization.
  # {AbstractDie} may be rejected where only numeric dice are expected.
  class NumericDie < AbstractDie
    # @param sides_list [Array<Numeric>, Range<Numeric>, Enumerable<Numeric>]
    # @raise [DiceyError] if +sides_list+ contains non-numerical values or is empty
    def initialize(sides_list)
      if Range === sides_list
        unless Integer === sides_list.begin && Integer === sides_list.end
          raise DiceyError, "`#{sides_list.inspect}` is not a valid range!"
        end
      else
        sides_list.each do |value|
          raise DiceyError, "`#{value.inspect}` is not a number!" unless Numeric === value
        end
      end

      super
    end
  end
end
