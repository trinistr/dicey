# frozen_string_literal: true

require_relative "../../dicey"

require_relative "options"

require_relative "calculator_runner"
require_relative "calculator_test_runner"
require_relative "roller"
require_relative "verbose_printer"

Dir["formatters/*.rb", base: __dir__].each { require_relative _1 }

module Dicey
  module CLI
    # Slice and dice everything in the Dicey module to produce a useful result.
    # This is the entry point for the CLI.
    class Blender
      # How to transform option values from command-line arguments
      # to internally significant objects.
      OPTION_TRANSFORMATIONS = {
        mode: lambda(&:to_sym),
        result: lambda(&:to_sym),
        format: {
          "list" => Formatters::ListFormatter.new,
          "gnuplot" => Formatters::GnuplotFormatter.new,
          "yaml" => Formatters::YAMLFormatter.new,
          "json" => Formatters::JSONFormatter.new,
          "null" => Formatters::NullFormatter.new,
        }.freeze,
      }.freeze

      # What to run for every mode.
      # Every runner must respond to `call(arguments, **options)`
      # and return +true+, +false+ or a String.
      RUNNERS = {
        roll: Roller.new,
        distribution: CLI::CalculatorRunner.new,
        test: CLI::CalculatorTestRunner.new,
      }.freeze

      # Run the program, blending everything together.
      #
      # @param argv [Array<String>] arguments for the program
      # @return [Boolean]
      # @raise [DiceyError] anything can happen
      def call(argv = ARGV)
        options, arguments = get_options_and_arguments(argv)
        require_optional_libraries(options)

        verbose_printer = VerbosePrinter.new(options[:verbosity])
        verbose_printer.print("Selected mode: #{options[:mode]}")

        return_value =
          RUNNERS[options.delete(:mode)]
          .call(arguments, **options, verbose_printer: verbose_printer)
        print return_value if return_value.is_a?(String)
        !!return_value
      end

      private

      def get_options_and_arguments(argv)
        options = Options.new
        arguments = options.read(argv)
        options = options.to_h
        options.each_pair do |k, v|
          options[k] = OPTION_TRANSFORMATIONS[k][v] || v if OPTION_TRANSFORMATIONS[k]
        end
        [options, arguments]
      end

      # Require libraries only when needed, to cut on run time.
      def require_optional_libraries(options)
        case options[:format]
        when Formatters::YAMLFormatter
          require "yaml"
        when Formatters::JSONFormatter
          require "json"
        else
          # No additional libraries needed
        end
      end
    end
  end
end
