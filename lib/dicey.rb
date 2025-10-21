# frozen_string_literal: true

# Try to load "vector_number" pre-emptively.
begin
  require "vector_number"
rescue LoadError
  # VectorNumber not available, sad
end

# A library for calculating roll distributions and rolling dice.
#
# Includes several classes of dice:
# - {AbstractDie}, the base and most generic class;
# - {NumericDie}, a subclass for strictly numeric dice;
# - {RegularDie}, for the most common dice.
#
# See {AbstractDie} for API and more information.
#
# Roll distributions can be calculated via one of several algorithms
# in {DistributionCalculators},
# with automatic selection available via {DistributionCalculators::AutoSelector}.
#
# There are also a couple of utility classes:
# - {DistributionPropertiesCalculator} for analyzing a distribution;
# - {DieFoundry} for creating dice from strings.
module Dicey
  # General error for Dicey.
  class DiceyError < StandardError; end

  require_relative "dicey/abstract_die"
  require_relative "dicey/numeric_die"
  require_relative "dicey/regular_die"

  require_relative "dicey/die_foundry"

  require_relative "dicey/distribution_properties_calculator"
  Dir["dicey/distribution_calculators/*.rb", base: __dir__].each { require_relative _1 }

  require_relative "dicey/version"
end
