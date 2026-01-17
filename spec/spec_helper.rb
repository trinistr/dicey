# frozen_string_literal: true

# Load all support files except coverage_helper first
Dir["#{__dir__}/support/**/*.rb"].each { require _1 unless _1.end_with?("coverage_helper.rb") }

# We don't want to have coverage for vector_number.
require "vector_number"
# Require coverage helper before the gem to ensure proper coverage reporting.
require_relative "support/coverage_helper"

require "dicey"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = "tmp/spec_status.txt"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Enable stable random order (use with --seed)
  config.order = :random
  Kernel.srand(config.seed)

  # Show detailed results for a single file, progress otherwise
  config.formatter = (config.files_to_run.size > 1) ? :progress : :documentation

  # Auto-focus examples when present
  config.filter_run_when_matching :focus
end
