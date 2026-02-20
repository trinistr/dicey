# frozen_string_literal: true

module Dicey
  module CLI
    # Prints verbose output to the given IO object.
    class VerbosePrinter
      def initialize(verbosity, io = $stdout)
        @verbosity = verbosity || 0
        @io = io
      end

      # Prints the given message to the IO object if the verbosity level
      # is greater than or equal to the minimum verbosity level.
      #
      # @param message [String]
      # @param min_verbosity [Integer]
      def print(message, min_verbosity = 1)
        @io.puts message if @verbosity >= min_verbosity
      end
    end
  end
end
