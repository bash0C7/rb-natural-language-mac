# frozen_string_literal: true

# Run with:
#   bundle exec ruby examples/embed_sentence.rb "<sentence>" "<language>"
#
# Defaults to English (Apple ships sentence embedding only for en/it
# on macOS 26.4.1; other languages return [] / 0).

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "natural_language_mac"

text = ARGV[0] || "Today is a fine day. Let us talk about programming."
language = ARGV[1] || "en"

dim = NaturalLanguageMac.embedding_dimension(language)
puts "Dimension for '#{language}': #{dim}"
if dim.zero?
  puts "No sentence embedding model is available for '#{language}' on this machine."
  puts "Apple ships NLEmbedding sentence models only for en/it as of macOS 26.4.1."
  exit 0
end

vec = NaturalLanguageMac.embed_sentence(text, language)
puts "Vector for #{text.inspect}:"
puts "  size: #{vec.size}"
puts "  head: #{vec.first(5).map { |v| format('%.4f', v) }.join(', ')}"
puts "  tail: #{vec.last(5).map { |v| format('%.4f', v) }.join(', ')}"
