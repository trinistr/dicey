# frozen_string_literal: true

require_relative "abstract_die"

module Dicey
  # A die which only has numeric sides, with no shenanigans.
  class NumericDie < AbstractDie
    # @param sides_list [Enumerable<Numeric>]
    # @raise [DiceyError] if +sides_list+ contains non-numerical values or is empty
    def initialize(sides_list)
      sides_list.each do |value|
        raise DiceyError, "`#{value}` is not a number!" unless value.is_a?(Numeric)
      end
      super
    end
  end
end
