# frozen_string_literal: true

require "optparse"

module Dicey
  module CLI
    # Helper class for parsing command-line options and generating help.
    class Options
      # Allowed modes (--mode) (only directly selectable).
      MODES = %w[distribution roll].freeze
      # Allowed result types (--result).
      RESULT_TYPES = %w[weights probabilities].freeze
      # Allowed output formats (--format).
      FORMATS = %w[list gnuplot json yaml null].freeze

      # Default values for initial values of the options.
      DEFAULT_OPTIONS = { mode: "distribution", format: "list", result: "weights" }.freeze

      def initialize(initial_options = DEFAULT_OPTIONS.dup)
        @options = initial_options
        @parser = ::OptionParser.new
        @parser.program_name = "Dicey"
        @parser.version = Dicey::VERSION

        add_banner_and_version
        add_common_options
        add_test_options
        add_other_options
      end

      # Parse command-line arguments as options and return non-option arguments.
      #
      # @param argv [Array<String>]
      # @return [Array<String>] non-option arguments
      def read(argv)
        @parser.parse!(argv, into: @options)
      end

      # Get an option value by key.
      #
      # @param key [Symbol]
      # @return [Object]
      def [](key)
        @options[key]
      end

      # @return [Hash{Symbol => Object}]
      def to_h
        @options.dup
      end

      private

      def add_banner_and_version
        @parser.banner = <<~TEXT
          Usage: dicey [options] <die> [<die> ...]
                 dicey [options] -- <die> [<die> ...]
                 dicey --test [full|quiet]
          All option names and arguments can be abbreviated if abbreviation is unambiguous.
          A lone "--" separates options and die definitions, allowing definitions to start with "-".
        TEXT
      end

      def add_common_options
        easy_option("-m", "--mode MODE", MODES, "What kind of action or calculation to perform.")
        easy_option("-r", "--result RESULT_TYPE", RESULT_TYPES,
                    "Select type of result to calculate (only for distribution).")
        easy_option("-f", "--format FORMAT", FORMATS, "Select output format for results.")
      end

      def add_test_options
        @parser.on_tail(
          "--test [REPORT_STYLE]", %w[full quiet],
          "Check predefined calculation cases and exit.",
          "REPORT_STYLE can be: `full`, `quiet`.", "`full` is default."
        ) do |report_style|
          @options[:mode] = :test
          @options[:report_style] = report_style&.to_sym || :full
        end
      end

      def add_other_options
        @parser.on_tail("-h", "--help", "Show this help and exit.") do
          puts @parser.help
          exit
        end
        @parser.on_tail("-V", "--version", "Show program version and exit.") do
          puts @parser.ver
          exit
        end
        @parser.on_tail("-v", "(Deprecated) Show program version and exit.") do
          puts @parser.ver
          exit
        end
      end

      def easy_option(short, long, values, description, &block)
        option_name = long[/[a-z_]+/].to_sym
        argument_name = long[/[A-Z_]+/]
        listed_values = "#{argument_name} can be: #{values.map { "`#{_1}`" }.join(", ")}."
        default_value = "`#{@options[option_name]}` is default."
        @parser.on(
          *[short, long, values, description, listed_values, default_value].compact, &block
        )
      end
    end
  end
end
