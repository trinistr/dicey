# frozen_string_literal: true

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
end
