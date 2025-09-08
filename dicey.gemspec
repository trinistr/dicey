# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = File.basename(__FILE__, ".gemspec")
  spec.version = File.read("lib/#{spec.name}/version.rb")[/(?<=VERSION = ")[\d.]+/]
  spec.authors = ["Alexandr Bulancov"]

  spec.homepage = "https://github.com/trinistr/#{spec.name}"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.summary = "Calculator of dice roll frequencies/probabilities. Also rolls dice."
  # spec.description = "TODO: Write a longer description or delete this line."

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{lib,sig,exe}/**/*"].select { File.file?(_1) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { File.basename(_1) }

  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["README.md"]
end
