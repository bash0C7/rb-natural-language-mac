# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "natural_language_mac"

text = ARGV[0] || "Today is a fine day. Let us talk about programming."
language = ARGV[1] || "en"

dim = NaturalLanguageMac.embedding_dimension(language)
puts "Dimension for '#{language}': #{dim}"
if dim.zero?
  puts "No sentence embedding model is available for '#{language}' on this machine."
  puts "Use NaturalLanguageMac.embed_contextual for this language instead."
  exit 0
end

vec = NaturalLanguageMac.embed_sentence(text, language)
puts "Vector for #{text.inspect}:"
puts "  size: #{vec.size}"
puts "  head: #{vec.first(5).map { |v| format('%.4f', v) }.join(', ')}"
puts "  tail: #{vec.last(5).map { |v| format('%.4f', v) }.join(', ')}"
