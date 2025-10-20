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

  Dir["dicey/mixins/*.rb", base: __dir__].each { require_relative _1 }
  Dir["dicey/*.rb", base: __dir__].each { require_relative _1 }
  Dir["dicey/sum_frequency_calculators/*.rb", base: __dir__].each { require_relative _1 }
end
