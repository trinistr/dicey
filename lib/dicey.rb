# frozen_string_literal: true

# Try to load "vector_number" pre-emptively.
begin
  require "vector_number"
rescue LoadError
  # VectorNumber not available, sad
end

# A library for rolling dice and calculating roll frequencies.
module Dicey
  # General error for Dicey.
  class DiceyError < StandardError; end

  require_relative "dicey/abstract_die"
  require_relative "dicey/numeric_die"
  require_relative "dicey/regular_die"

  require_relative "dicey/die_foundry"

  require_relative "dicey/distribution_properties_calculator"
  Dir["dicey/sum_frequency_calculators/*.rb", base: __dir__].each { require_relative _1 }

  require_relative "dicey/version"
end
