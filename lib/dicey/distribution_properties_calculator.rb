# frozen_string_literal: true

require_relative "mixins/rational_to_integer"

module Dicey
  # @note This class is considered experimental. It may be changed at any point.
  #
  # Calculates distribution properties,
  # also known as descriptive statistics when applied to a population sample.
  #
  # These are well-known properties such as:
  # - min, max, mid-range;
  # - mode(s), median, arithmetic mean;
  # - important moments (expected value, variance, skewness, kurtosis).
  #
  # Distributions are assumed to be complete populations,
  # i.e. this class is unsuitable for samples.
  #
  # It is notable that common dice create symmetric distributions,
  # which means that skewness is 0, while measures of central tendency
  # (median, mean, ...) are all equal.
  # Mode is often not unique, but includes this center.
  class DistributionPropertiesCalculator
    include Mixins::RationalToInteger

    # Calculate properties for a given distribution.
    #
    # Depending on values in the distribution, some properties may be undefined.
    # In such cases, only mode(s) are guaranteed to be present.
    #
    # On empty distribution, returns an empty hash.
    #
    # @param distribution [Hash{Numeric => Numeric}, Hash{Any => Numeric}]
    #   distribution with pre-sorted keys
    # @return [Hash{Symbol => Any}]
    def call(distribution)
      return {} if distribution.empty?

      calculate_properties(distribution)
    end

    private

    def calculate_properties(distribution)
      outcomes = distribution.keys
      weights = distribution.values

      {
        mode: mode(outcomes, weights),
        modes: modes(distribution),
        **range_characteristics(outcomes),
        **median(outcomes),
        **means(outcomes, weights),
        **moments(distribution),
      }
    end

    def mode(outcomes, weights)
      max_weight = weights.max
      outcomes.select.with_index { |_, index| weights[index] == max_weight }
    end

    def modes(distribution)
      # Split into chunks with different weights,
      # then select those with higher weights than their neighbors.
      chunks = distribution.chunk_while { |(_, w_1), (_, w_2)| w_1 == w_2 }.to_a
      return [chunks.first.map(&:first)] if chunks.size == 1

      modes = []
      add_local_mode(modes, nil, chunks[0], chunks[1])
      chunks.each_cons(3).each do |chunk_before, chunk, chunk_after|
        add_local_mode(modes, chunk_before, chunk, chunk_after)
      end
      add_local_mode(modes, chunks[-2], chunks[-1], nil)
      modes
    end

    def add_local_mode(modes, chunk_before, chunk, chunk_after)
      if (!chunk_before || chunk_before.first.last < chunk.first.last) &&
         (!chunk_after || chunk_after.first.last < chunk.first.last)
        modes << chunk.map(&:first)
      end
    end

    def range_characteristics(outcomes)
      min = outcomes.min
      max = outcomes.max
      {
        min: min,
        max: max,
        range_length: max - min,
        mid_range: rational_to_integer(Rational(min + max, 2)),
      }
    rescue ArgumentError, TypeError, NoMethodError
      # Outcomes are not comparable with each other, so a range can not be determined.
      {}
    end

    def means(outcomes, _weights)
      {
        arithmetic_mean: rational_to_integer(Rational(outcomes.sum, outcomes.size)),
      }
    rescue ArgumentError, TypeError
      # Outcomes are not summable with each other, means are meaningless.
      {}
    end

    def median(outcomes)
      outcomes = outcomes.sort
      value =
        if outcomes.size.odd?
          outcomes[outcomes.size / 2]
        else
          Rational(outcomes[(outcomes.size / 2) - 1] + outcomes[outcomes.size / 2], 2)
        end
      { median: value }
    rescue ArgumentError, TypeError, NoMethodError
      # Outcomes are not compatible with each other, so a median can not be determined.
      {}
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
        excess_kurtosis: kurtosis ? kurtosis - 3 : nil,
      }
    rescue ArgumentError, TypeError, NoMethodError
      # Outcomes are not compatible with each other, moments are fleeing.
      {}
    end

    def moment(distribution, total_weight, degree, center = 0, variance = nil)
      # With 0 variance, normalized moments are undefined.
      return nil if variance == 0 # rubocop:disable Style/NumericPredicate

      unnormalized = distribution.sum { |r, w| ((r - center)**degree) * Rational(w, total_weight) }
      variance ? (unnormalized / (variance**(degree/2r))) : unnormalized
    end
  end
end
