# frozen_string_literal: true

module Dicey
  module Mixins
    # @api private
    # Some math functions missing from Math, though without argument range checks.
    module MissingMath
      module_function

      # Calculate number of combinations of +n+ elements taken +k+ at a time.
      #
      # Unlike plain binomial coefficients, combinations are defined as 0 for +k > n+.
      #
      # @param n [Integer] natural integer
      # @param k [Integer] natural integer
      # @return [Integer]
      def combinations(n, k) # rubocop:disable Naming/MethodParameterName
        return 0 if k > n
        return 1 if k.zero? || k == n

        factorial_quo(n, k) / factorial(n - k)
      end

      # Calculate factorial of a natural number.
      #
      # @param n [Integer] natural integer
      # @return [Integer]
      def factorial(n) # rubocop:disable Naming/MethodParameterName
        (n < 23) ? Math.gamma(n + 1).to_i : (1..n).reduce(:*)
      end

      # Calculate +n! / k!+ where +n >= k+.
      #
      # @param n [Integer] natural integer
      # @param k [Integer] natural integer
      # @return [Integer]
      def factorial_quo(n, k) # rubocop:disable Naming/MethodParameterName
        return Math.gamma(n + 1).to_i / Math.gamma(k + 1).to_i if n < 23 && k < 23

        ((k + 1)..n).reduce(:*)
      end
    end
  end
end
