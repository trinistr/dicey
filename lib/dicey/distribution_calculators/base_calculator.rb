# frozen_string_literal: true

module Dicey
  # Calculators for probability distributions of dice.
  module DistributionCalculators
    # Base frequencies calculator.
    #
    # *Result types:*
    # - +:frequencies+ (default)
    # - +:probabilities+
    #
    # By default, returns frequencies as they are easier to calculate and
    # can be represented with integers.
    # Probabilities are calculated using +Rational+ numbers to return exact results.
    #
    # *Options:*
    #
    # Calculators may have calculator-specific options,
    # passed as extra keyword arguments to {#call}.
    # If present, they will be documented under *Options* heading
    # on the class itself.
    #
    # @abstract
    class BaseCalculator
      # Possible values for +result_type+ argument in {#call}.
      RESULT_TYPES = %i[frequencies probabilities].freeze

      # Calculate distribution (probability mass function) for the list of dice.
      #
      # Returns empty hash for an empty list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @param options [Hash{Symbol => Any}] calculator-specific options,
      #   refer to the calculator's documentation to see what it accepts
      # @return [Hash{Numeric => Numeric}] frequencies or probabilities for each outcome
      # @raise [DiceyError] if +result_type+ is invalid
      # @raise [DiceyError] if dice list is invalid for the calculator
      # @raise [DiceyError] if calculator returned obviously wrong results
      def call(dice, result_type: :frequencies, **options)
        unless RESULT_TYPES.include?(result_type)
          raise DiceyError, "#{result_type} is not a valid result type!"
        end
        # Short-circuit for a degenerate case.
        return {} if dice.empty?
        raise DiceyError, "#{self.class} can not handle these dice!" unless valid_for?(dice)

        frequencies = calculate(dice, **options)
        verify_result(frequencies, dice)
        frequencies = sort_result(frequencies)
        transform_result(frequencies, result_type)
      end

      # Whether this calculator can be used for the list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Boolean]
      def valid_for?(dice)
        dice.is_a?(Enumerable) && dice.all?(AbstractDie) && validate(dice)
      end

      # Heuristic complexity of the calculator, used to determine best calculator.
      #
      # Returns 0 for an empty list of dice.
      #
      # @see AutoSelector
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Integer]
      def heuristic_complexity(dice)
        return 0 if dice.empty?

        calculate_heuristic(dice.length, dice.map(&:sides_num).max).to_i
      end

      private

      # Do additional validation on the dice list.
      # (see #valid_for?)
      def validate(_dice)
        true
      end

      # Calculate heuristic complexity of the calculator.
      #
      # @param dice_count [Integer]
      # @param sides_count [Integer] maximum number of sides
      # @return [Numeric]
      def calculate_heuristic(dice_count, sides_count)
        raise NotImplementedError
      end

      # Peform frequencies calculation.
      # (see #call)
      def calculate(dice, **nil)
        raise NotImplementedError
      end

      # Check that resulting frequencies actually add up to what they are supposed to be.
      #
      # @param frequencies [Hash{Numeric => Integer}]
      # @param dice [Enumerable<AbstractDie>]
      # @return [void]
      # @raise [DiceyError] if result is wrong
      def verify_result(frequencies, dice)
        valid = frequencies.values.sum == (dice.map(&:sides_num).reduce(:*) || 0)
        raise DiceyError, "calculator #{self.class} returned invalid results!" unless valid
      end

      # Depending on the order of sides, result may not be in an ascending order,
      # so it's best to fix that for presentation (if possible).
      def sort_result(frequencies)
        frequencies.sort.to_h
      rescue
        # Probably Complex numbers got into the mix, leave as is.
        frequencies
      end

      # Transform calculated frequencies to requested result_type, if needed.
      #
      # @param frequencies [Hash{Numeric => Integer}]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @return [Hash{Numeric => Numeric}]
      def transform_result(frequencies, result_type)
        if result_type == :frequencies
          frequencies
        else
          total = frequencies.values.sum
          frequencies.transform_values { Rational(_1, total) }
        end
      end
    end
  end
end
