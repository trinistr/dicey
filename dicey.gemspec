# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = File.basename(__FILE__, ".gemspec")
  spec.version = File.read("lib/#{spec.name}/version.rb")[/(?<=VERSION = ")[\d.]+/]
  spec.authors = ["Alexandr Bulancov"]

  spec.homepage = "https://github.com/trinistr/#{spec.name}"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.summary = "Calculator for dice roll frequency/probability distributions. Also rolls dice."
  spec.description = <<~TEXT
    Dicey provides a CLI executable and a Ruby API for fast calculation of
    frequency/probability distributions of dice rolls,
    with support for all kinds of numeric dice, even Complex ones!
    Results can be exported as JSON, YAML or a gnuplot data file.

    It can also be used to roll dice. While not the primary focus,
    rolling is well supported, including ability to seed random source
    for reproducible results.
  TEXT

  # Library for doing math on arbitrary objects.
  spec.add_development_dependency "vector_number", ">= 0.4.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{lib,exe}/**/*"].select { File.file?(_1) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { File.basename(_1) }

  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["README.md"]
end
