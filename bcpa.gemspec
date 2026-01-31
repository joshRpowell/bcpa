# frozen_string_literal: true

require_relative "lib/bcpa/version"

Gem::Specification.new do |spec|
  spec.name = "bcpa"
  spec.version = BCPA::VERSION
  spec.authors = ["Joshua Powell"]
  spec.email = ["joshua@joshuapowell.com"]

  spec.summary = "CLI for Broward County Property Appraiser"
  spec.description = "Search and cross-reference property records from the Broward County Property Appraiser (BCPA)"
  spec.homepage = "https://github.com/joshuapowell/bcpa"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = ["bcpa"]
  spec.require_paths = ["lib"]

  spec.add_dependency "terminal-table", "~> 3.0"
  spec.add_dependency "thor", "~> 1.3"
end
