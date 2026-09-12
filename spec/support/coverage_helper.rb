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
  enable_coverage :eval

  group "Lib", "lib"
  group "Tests", "spec"
  remove_filter %r{\A(test|features|spec|autotest)/}

  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
rescue RuntimeError => e
  raise unless e.message.start_with?("Unsupported coverage criterion eval")

  warn "simplecov is too old, coverage report will not be generated!"
end
