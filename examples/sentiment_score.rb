# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "natural_language_mac"

text = ARGV[0] || "I love this. It is wonderful and amazing!"

score = NaturalLanguageMac.sentiment_score(text)
puts "Text:  #{text.inspect}"
puts "Score: #{score.inspect}"

if score.nil?
  puts
  puts "sentiment_score returned nil. This is expected for languages with no"
  puts "sentiment model, such as Japanese."
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
