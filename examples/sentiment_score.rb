# frozen_string_literal: true

# Run with:
#   bundle exec ruby examples/sentiment_score.rb "<text>"
#
# Defaults to an English sentence. sentiment_score returns a Float roughly in
# -1.0..1.0 (0.0 is a valid neutral score, distinct from nil failure).
#
# Apple ships no Japanese sentiment model on macOS 26.4.1, so Japanese input
# returns nil. The workaround shown below translates JA -> EN via
# rb-translation-mac, then scores the English text.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "natural_language_mac"

text = ARGV[0] || "I love this. It is wonderful and amazing!"

score = NaturalLanguageMac.sentiment_score(text)
puts "Text:  #{text.inspect}"
puts "Score: #{score.inspect}"

if score.nil?
  puts
  puts "sentiment_score returned nil. This is expected for languages with no"
  puts "sentiment model (e.g. Japanese on macOS 26.4.1)."
  puts "Workaround: translate to English first, then score."

  begin
    $LOAD_PATH.unshift File.expand_path(
      "../../rb-translation-mac/lib", __dir__
    )
    require "translation_mac"
  rescue LoadError => e
    puts "  (rb-translation-mac not available, skipping workaround demo: #{e.message})"
    exit 0
  end

  result = TranslationMac.translate(text, from: "ja", to: "en")
  if result.success
    en_text = result.text
    en_score = NaturalLanguageMac.sentiment_score(en_text)
    puts "  translated: #{en_text.inspect}"
    puts "  EN score:   #{en_score.inspect}"
  else
    puts "  translation failed: #{result.error.inspect}"
  end
end
