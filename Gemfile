# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# All gems that aren't actually used in code should have "require: false".
# This is needed for RBS, because otherwise it will install insane number of definitions.
# Alternatively, ignore them in `rbs_collection.yaml`.

# For running tasks
gem "rake", require: false

group :test do
  # Testing framework
  gem "rspec", require: false

  # Code coverage report
  gem "simplecov", require: false
  gem "simplecov_lcov_formatter", require: false
end

group :linting do
  # Linting
  gem "rubocop", "~> 1.72", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-yard", require: false

  # Checking type signatures
  gem "rbs", require: false
  # Checking types in code
  gem "steep", require: false
end

group :documentation do
  # Documentation generation
  gem "redcarpet", require: false
  gem "yard", require: false
end

group :development do
  # Automatic updates for version changes
  gem "bump", require: false

  # Benchmarking and profiling
  gem "benchmark", require: false
  gem "benchmark-ips", require: false
  gem "stackprof", require: false

  # For console
  gem "irb", require: false if RUBY_VERSION >= "3.5.0"
end
