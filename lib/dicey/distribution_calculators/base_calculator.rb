# frozen_string_literal: true

require_relative "../mixins/vectorize_dice"

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
      include Mixins::VectorizeDice

      # Possible values for +result_type+ argument in {#call}.
      RESULT_TYPES = %i[weights probabilities].freeze

      # Calculate distribution (probability mass function) for the list of dice.
      #
      # Returns empty hash for an empty list of dice.
      #
      # @note Calculation is supposed to return exact results.
      #   Using dice with +Float+ values can break this promise and raise errors.
      #   Please use +Integer+, +Rational+ or +BigDecimal+ instead.
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
        raise DiceyError, "dice must be an Enumerable!" unless Enumerable === dice
        # Short-circuit for a degenerate case.
        return {} if dice.empty?

        static_dice, normal_dice = dice.partition { StaticDie === _1 }
        raise DiceyError, "#{self.class} can not handle these dice!" unless valid_for?(normal_dice)

        distribution = prepare_distribution(normal_dice, static_dice, options)
        verify_result(distribution, dice)
        transform_result(distribution, result_type)
      end

      # Whether this calculator can be used for the list of dice.
      #
      # {StaticDie} instances are always ignored.
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Boolean]
      def valid_for?(dice)
        return false if !(Enumerable === dice) || !dice.all?(AbstractDie)

        normal_dice = dice.grep_v(StaticDie)
        return true if normal_dice.none?

        validate(normal_dice)
      end

      # Heuristic complexity of the calculator, used to determine best calculator.
      #
      # Will always return a value, even if the calculator is not valid for the dice.
      #
      # @see AutoSelector
      #
      # @param dice [Enumerable<AbstractDie>]
      # @return [Integer] 0 if +dice+ is empty, otherwise can be any value
      def heuristic_complexity(dice)
        return 0 if dice.empty?

        calculate_heuristic(dice.grep_v(StaticDie).length, dice.map(&:sides_num).max).to_i
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

      # Prepare distribution by calculating it for normal dice and adding static dice to it.
      #
      # @param normal_dice [Enumerable<AbstractDie>]
      # @param static_dice [Enumerable<StaticDie>]
      # @param options [Hash]
      # @return [Hash{Any => Integer}]
      def prepare_distribution(normal_dice, static_dice, options)
        if normal_dice.any?
          distribution = calculate(normal_dice, **options)
          distribution = sort_result(distribution)
        else
          # We can't get to this point if there are no dice at all,
          # so prepare a "nothing" distribution to add static dice to it.
          distribution = { 0 => 1 }
        end

        if static_dice.any?
          c = vectorize_dice(static_dice).sum(&:value)
          # This is done via `+=` because different `k + c` can produce the same key.
          distribution = distribution.each_with_object(Hash.new(0)) { |(k, v), h| h[k + c] += v }
          distribution.default = nil
        end

        distribution
      end

      # Check that resulting weights actually add up to what they are supposed to be.
      #
      # @param distribution [Hash{Any => Integer}]
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
      # @param distribution [Hash{Any => Integer}]
      # @param result_type [Symbol] one of {RESULT_TYPES}
      # @return [Hash{Any => Numeric}]
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
