# frozen_string_literal: true

module Dicey
  # Classes pertaining to CLI.
  # NOT loaded by default, use +require "dicey/cli/blender"+ as needed.
  module CLI
    require_relative "../../dicey"
    require_relative "options"

    # Slice and dice everything in the Dicey module to produce a useful result.
    # This is the entry point for the CLI.
    class Blender
      # How to transform option values from command-line arguments
      # to internally significant objects.
      OPTION_TRANSFORMATIONS = {
        mode: lambda(&:to_sym),
        result: lambda(&:to_sym),
        format: {
          "list" => OutputFormatters::ListFormatter.new,
          "gnuplot" => OutputFormatters::GnuplotFormatter.new,
          "yaml" => OutputFormatters::YAMLFormatter.new,
          "json" => OutputFormatters::JSONFormatter.new,
          "null" => OutputFormatters::NullFormatter.new,
        }.freeze,
      }.freeze

      # What to run for every mode.
      # Every runner must respond to `call(arguments, **options)`
      # and return +true+, +false+ or a String.
      RUNNERS = {
        roll: Roller.new,
        frequencies: SumFrequencyCalculators::Runner.new,
        test: SumFrequencyCalculators::TestRunner.new,
      }.freeze

      # Run the program, blending everything together.
      #
      # @param argv [Array<String>] arguments for the program
      # @return [Boolean]
      # @raise [DiceyError] anything can happen
      def call(argv = ARGV)
        options, arguments = get_options_and_arguments(argv)
        require_optional_libraries(options)
        return_value = RUNNERS[options.delete(:mode)].call(arguments, **options)
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
        when OutputFormatters::YAMLFormatter
          require "yaml"
        when OutputFormatters::JSONFormatter
          require "json"
        else
          # No additional libraries needed
        end
      end
    end
  end
end
