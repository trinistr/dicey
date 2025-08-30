# frozen_string_literal: true

Dir["#{__dir__}/dicey/**/*.rb"].each { require _1 }

# A library for rolling dice and calculating roll frequencies.
module Dicey
  # General error for Dicey.
  class DiceyError < StandardError; end
end
