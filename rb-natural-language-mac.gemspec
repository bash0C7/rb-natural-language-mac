# frozen_string_literal: true

require_relative "lib/natural_language_mac/version"

Gem::Specification.new do |spec|
  spec.name = "rb-natural-language-mac"
  spec.version = NaturalLanguageMac::VERSION
  spec.authors = ["bash0C7"]
  spec.email = ["ksb.4038.nullpointer+github@gmail.com"]

  spec.summary = "Ruby binding for Apple Natural Language framework on macOS: detection, tokenization, tagging, sentiment, embeddings"
  spec.description = "Calls Apple NaturalLanguage framework's language detection, tokenization, lexical tagging, sentiment scoring, and sentence/contextual embeddings from Ruby on macOS / Apple Silicon. Built on top of swift_gem."
  spec.homepage = "https://github.com/bash0C7/rb-natural-language-mac"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bash0C7/rb-natural-language-mac"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/natural_language_mac/extconf.rb"]
end
