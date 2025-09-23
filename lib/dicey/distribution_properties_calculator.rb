# frozen_string_literal: true

require_relative "rational_to_integer"

module Dicey
  # Calculates distribution properties,
  # also known as descriptive statistics when applied to a population sample.
  #
  # These are well-known properties such as:
  # - min, max, mid-range;
  # - mode, median, arithmetic mean;
  # - important moments (expected value, variance, skewness, kurtosis).
  #
  # It is notable that most dice create symmetric distributions,
  # which means that skewness is 0, while properties denoting center in some way
  # (median, mean, ...) are all equal.
  # Mode is often not unique, but includes this center.
  class DistributionPropertiesCalculator
    # Calculate properties for a given distribution.
    #
    # @param distribution [Hash{Numeric => Numeric}
    #   numeric distribution with pre-sorted keys
    # @return [Hash{Symbol => Numeric, Array<Numeric>}]
    def call(distribution)
      return {} if distribution.empty?

      calculate_properties(distribution)
    end

    private

    def calculate_properties(distribution)
      outcomes = distribution.keys
      weights = distribution.values

      {
        **range_characteristics(outcomes),
        **means(outcomes, weights),
        **moments(distribution),
      }
    end

    def range_characteristics(outcomes)
      min = outcomes.min
      max = outcomes.max
      {
        min: min,
        max: max,
        total_range: max - min,
        mid_range: rational_to_integer(Rational(min + max, 2)),
      }
    end

    def means(outcomes, weights)
      max_weight = weights.max
      {
        mode: outcomes.select.with_index { |_, index| weights[index] == max_weight },
        median: median(outcomes),
        arithmetic_mean: rational_to_integer(Rational(outcomes.sum, outcomes.size)),
      }
    end

    def median(outcomes)
      if outcomes.size.odd?
        outcomes[outcomes.size / 2]
      else
        Rational(outcomes[(outcomes.size / 2) - 1] + outcomes[outcomes.size / 2], 2)
      end
    end

    def moments(distribution)
      total_weight = distribution.values.sum
      expected_value = rational_to_integer(moment(distribution, total_weight, 1))
      variance = rational_to_integer(moment(distribution, total_weight, 2) - (expected_value**2))
      skewness =
        rational_to_integer(moment(distribution, total_weight, 3, expected_value, variance))
      kurtosis =
        rational_to_integer(moment(distribution, total_weight, 4, expected_value, variance))

      {
        expected_value: expected_value,
        variance: variance,
        standard_deviation: Math.sqrt(variance),
        skewness: skewness,
        kurtosis: kurtosis,
        excess_kurtosis: kurtosis - 3,
      }
    end

    def moment(distribution, total_weight, degree, center = 0, variance = nil)
      unnormalized = distribution.sum { |r, w| ((r - center)**degree) * Rational(w, total_weight) }
      variance ? (unnormalized / (variance**Rational(degree, 2))) : unnormalized
    end
  end
end
