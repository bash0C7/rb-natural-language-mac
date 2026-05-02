#!/usr/bin/env ruby
# frozen_string_literal: true

# Run with: bundle exec ruby example.rb ["<text>"]
# Build the native extension first: bundle exec rake compile

require_relative "lib/natural_language_mac"

text = ARGV.first || "The quick brown fox jumps over the lazy dog."

puts "input:    #{text.inspect}"
puts "language: #{NaturalLanguageMac.detect_language(text)}"
puts
puts "tokens:"
puts NaturalLanguageMac.tokenize(text)
puts
puts "tags:"
puts NaturalLanguageMac.tag(text)
