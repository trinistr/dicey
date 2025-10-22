# frozen_string_literal: true

module Dicey
  module DistributionCalculators
    # Base class for implementing distribution calculators.
    #
    # Calculators have the following methods, each taking an array of dice:
    # - {#call} to actually calculate the distribution;
    # - {#valid_for?} to check if the calculator can handle the dice;
    # - {#heuristic_complexity} to determine the complexity of calculation,
    #   mostly useful for {AutoSelector}.
    #
    # By default, {#call} returns weights as they are easier to calculate and
    # can be represented with integers (except for {Empirical} calculator).
    # If probabilities are requested, they are calculated using +Rational+ numbers
    # to produce exact results.
    #
    # An empty list of dice is considered a degenerate case, always valid for any calculator.
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
      RESULT_TYPES = %i[weights probabilities].freeze

      # Calculate distribution (probability mass function) for the list of dice.
      #
      # Returns empty hash for an empty list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @param options [Hash{Symbol => Any}] calculator-specific options,
      #   refer to the calculator's documentation to see what it accepts
      # @return [Hash{Any => Numeric}] weight or probability for each outcome,
      #   sorted by outcome if possible
      # @raise [DiceyError] if +result_type+ is invalid
      # @raise [DiceyError] if +dice+ list is invalid for the calculator
      # @raise [DiceyError] if calculator returned obviously wrong results
      #   (should not happen in released versions)
      def call(dice, result_type: :weights, **options)
        unless RESULT_TYPES.include?(result_type)
          raise DiceyError, "#{result_type} is not a valid result type!"
        end
        raise DiceyError, "#{self.class} can not handle these dice!" unless valid_for?(dice)

        # Short-circuit for a degenerate case.
        return {} if dice.empty?

        distribution = calculate(dice, **options)
        verify_result(distribution, dice)
        distribution = sort_result(distribution)
        transform_result(distribution, result_type)
      end

      # Whether this calculator can be used for the list of dice.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Boolean]
      def valid_for?(dice)
        dice.is_a?(Enumerable) && (dice.empty? || (dice.all?(AbstractDie) && validate(dice)))
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

      # Calculate weights of outcomes for the dice.
      # (see #call)
      def calculate(dice, **nil)
        raise NotImplementedError
      end

      # Check that resulting weights actually add up to what they are supposed to be.
      #
      # @param distribution [Hash{Numeric => Integer}]
      # @param dice [Enumerable<AbstractDie>]
      # @return [void]
      # @raise [DiceyError] if result is wrong
      def verify_result(distribution, dice)
        valid = distribution.values.sum == (dice.map(&:sides_num).reduce(:*) || 0)
        raise DiceyError, "calculator #{self.class} returned invalid results!" unless valid
      end

      # Depending on the order of sides, result may not be in an ascending order,
      # so it's best to fix that for presentation (if possible).
      def sort_result(distribution)
        distribution.sort.to_h
      rescue
        # Sort failed, leave as is.
        distribution
      end

      # Transform calculated weights to requested result type, if needed.
      #
      # @param distribution [Hash{Numeric => Integer}]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @return [Hash{Numeric => Numeric}]
      def transform_result(distribution, result_type)
        if result_type == :weights
          distribution
        else
          total = distribution.values.sum
          distribution.transform_values { Rational(_1, total) }
        end
      end
    end
  end
end
