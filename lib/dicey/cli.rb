# frozen_string_literal: true

module Dicey
  # @api private
  # Classes pertaining to CLI. These are not intended to be used by API consumers.
  #
  # If you *really* need to simulate CLI from inside your code, use {.call}.
  #
  # @note Not loaded by default, use +require "dicey/cli"+ as needed.
  module CLI
    require_relative "cli/blender"

    # @api public
    # Parse options and arguments and run calculations, printing results.
    #
    # @param argv [Array<String>] arguments for the program
    # @return [Boolean]
    # @raise [DiceyError] anything can happen
    def self.call(argv = ARGV)
      Blender.new.call(argv)
    end
  end
end
