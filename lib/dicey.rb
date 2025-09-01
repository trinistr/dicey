# frozen_string_literal: true

# A library for rolling dice and calculating roll frequencies.
module Dicey
  # General error for Dicey.
  class DiceyError < StandardError; end

  Dir["#{__dir__}/dicey/*.rb"].each { require _1 }
  Dir["#{__dir__}/dicey/output_formatters/*.rb"].each { require _1 }
  Dir["#{__dir__}/dicey/sum_frequency_calculators/*.rb"].each { require _1 }
end
