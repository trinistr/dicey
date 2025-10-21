# frozen_string_literal: true

module Dicey
  # Classes pertaining to CLI.
  #
  # @note NOT loaded by default, use +require "dicey/cli"+ as needed.
  module CLI
    require_relative "cli/blender"

    # Run the program, passing arguments through the {Blender}.
    #
    # @param argv [Array<String>] arguments for the program
    # @return [Boolean]
    # @raise [DiceyError] anything can happen
    def self.call(argv = ARGV)
      Blender.new.call(argv)
    end
  end
end
