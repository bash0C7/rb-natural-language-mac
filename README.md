# rb-natural-language-mac

Ruby binding for Apple's Natural Language framework on macOS / Apple Silicon. Calls `NLLanguageRecognizer`, `NLTokenizer`, `NLTagger`, `NLEmbedding`, and `NLContextualEmbedding` from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 27+, Apple Silicon
- Xcode 27 (builds run `xcrun swift`)
- Ruby 4.0+, Bundler 4.x

## Installation

Install from source:

```bash
git clone https://github.com/bash0C7/rb-natural-language-mac.git
cd rb-natural-language-mac
bundle install
bundle exec rake compile
```

## Usage

```ruby
require "natural_language_mac"

NaturalLanguageMac.detect_language("これは日本語の文章です。")
# => "ja"

NaturalLanguageMac.tokenize("Hello world test.")
# => "Hello\nworld\ntest"

NaturalLanguageMac.tag("The quick fox jumps.")
# => "The\tDeterminer\nquick\tAdjective\nfox\tNoun\njumps\tVerb"

NaturalLanguageMac.sentiment_score("I love this. It is wonderful and amazing!")
# => 1.0

NaturalLanguageMac.embedding_dimension("en")
# => 512

NaturalLanguageMac.embed_sentence("Today is a fine day.", "en")
# => [0.4472, 0.2692, -0.2569, ...]

NaturalLanguageMac.contextual_dimension("ja")
# => 512

NaturalLanguageMac.embed_contextual("これは日本語の文章です", "ja")
# => [0.1234, -0.0567, ...]
```

`detect_language`, `tokenize`, and `tag` return a single newline-separated string. `tag` uses a tab between token and tag and skips whitespace and punctuation. They return `""` for empty input or when the framework returns nothing.

`sentiment_score(text)` returns a document-level sentiment as a `Float`, roughly `-1.0` (very negative) to `+1.0` (very positive), from `NLTagger` with the `.sentimentScore` scheme, `unit: .paragraph`, and the auto-detected language. One text in, one score out; split paragraphs upstream for per-paragraph scores. It returns `nil` on empty input or when Apple ships no sentiment model for the detected language. `0.0` is a genuine neutral score, distinct from `nil`.

**Japanese has no sentiment model**, so Japanese text returns `nil`. Two workarounds:

1. Pass English text directly.
2. Translate first, then score. The sibling gem [rb-translation-mac](https://github.com/bash0C7/rb-translation-mac) wraps Apple's on-device Translation framework:

   ```ruby
   require "natural_language_mac"
   require "translation_mac"

   ja = "これはとても素晴らしい一日でした。本当に楽しかったです。"
   en = TranslationMac.translate(ja, from: "ja", to: "en")
   NaturalLanguageMac.sentiment_score(en.text) if en.success
   # => 1.0
   ```

   Translation is lossy, so treat the result as a coarse signal. Apple's English sentiment is itself approximate: neutral, matter-of-fact sentences can score clearly negative. Validate against your own text before building a threshold on it.

`embed_sentence(text, language)` returns the sentence embedding from `NLEmbedding.sentenceEmbedding(for:)` as an `Array<Float>` of size `embedding_dimension(language)`. Apple ships sentence embeddings for a set of Latin-script languages such as `en`, `fr`, `de`, `es`, and `it`, but not for `ja`, `zh-Hans`, or `ko`. Both methods return `[]` / `0` on empty arguments or when no model ships for the language.

`embed_contextual(text, language)` returns a sentence vector by mean-pooling the token vectors of `NLContextualEmbedding(language:)`, as an `Array<Float>` of size `contextual_dimension(language)`. Its language coverage is much wider, and it is the path for Japanese, Chinese, and Korean sentence vectors. The model assets are downloaded by macOS; this gem does not request them, and returns `[]` when they are not on the device. Both methods return `[]` / `0` on empty arguments or an unsupported language.

Open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Preconditions: caller is responsible for input quality

This gem passes text to Apple's stock models as-is. It does no encoding fixup, language hinting, domain customization, or model swapping.

Apple's NL framework has known weak spots:

- **Very short text** (`detect_language`). `NLLanguageRecognizer` is unreliable on inputs of a few words; a single word may get the wrong language or `""`. Aggregate context before detecting.
- **Mixed-language text**. Only the dominant language is returned. Split into sentences upstream for per-segment detection.
- **Language coverage**. Latin, CJK, Cyrillic, and Arabic are covered well; Indic, South-East Asian, and African scripts are uneven.
- **Domain-specific tagging** (`tag`). The lexical-class tagger targets general text. Code, medical or legal jargon, social-media slang, and OCR output may be mis-tagged, and the model cannot be swapped from this gem.
- **Encoding**. The C bridge expects UTF-8. Normalize (for example `String#unicode_normalize(:nfc)`) if you mix NFC and NFD input.

All methods return the same empty value for "framework returned nothing", "empty input", and "no model for this language". Branch on `empty?` / `nil?` / `zero?` and apply your own fallback. Non-string arguments raise `TypeError`.

## Reference: Ruby examples

```bash
bundle exec rake compile
bundle exec ruby example.rb "The quick brown fox jumps over the lazy dog."
bundle exec ruby examples/embed_sentence.rb "Hello world." "en"
bundle exec ruby examples/sentiment_score.rb "これはとても素晴らしい一日でした。"
```

`example.rb` runs detection, tokenization, tagging, and sentiment on one text. `examples/embed_sentence.rb` prints a sentence embedding. `examples/sentiment_score.rb` scores a text and, when the score is `nil`, translates it to English with a sibling checkout of rb-translation-mac and scores again.

## Reference: pure Swift sample

`examples/natural_language_mac.swift` runs detection, tokenization, and tagging without Ruby:

```bash
xcrun swift examples/natural_language_mac.swift "Hello world."
```

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` validates `sig/natural_language_mac.rbs`, runs `xcrun swift build -c release --package-path ext/natural_language_mac`, builds the C extension into `lib/natural_language_mac/natural_language_mac.bundle`, then runs the tests. `bundle exec rake compile` runs only the build.

## License

MIT.
