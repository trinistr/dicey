# frozen_string_literal: true

begin
  require "simplecov"
  require "simplecov_lcov_formatter"
rescue LoadError
  warn "simplecov is not available, coverage report will not be generated!"
  return
end

SimpleCov.start do
  enable_coverage :branch
  enable_coverage_for_eval

  add_group "Lib", "lib"
  add_group "Tests", "spec"

  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
end
