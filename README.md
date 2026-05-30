# rb-natural-language-mac

Ruby binding for Apple's Natural Language framework on macOS / Apple Silicon. Calls `NLLanguageRecognizer`, `NLTokenizer`, and `NLTagger` directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute; the hard floor) for the library build. Install via [swiftly](https://www.swift.org/install/macos/).
- Ruby 3.2+ (gemspec `required_ruby_version`), Bundler 4.x
- **Xcode Command Line Tools** only if you want to run `examples/natural_language_mac.swift`. The pure-Swift sample must run under `xcrun swift`; swiftly's 6.3 swift binary cannot JIT-link Apple system frameworks (NaturalLanguage) in interpret mode. The library build itself does not need CLT. Install with `xcode-select --install`.

Verified on macOS 26.4.1 / Apple Silicon / Ruby 4.0.3. The lower bounds above are the intended minimums; builds at the floor are not yet verified.

## Installation

Not yet published. Install from source against a local checkout of its `swift_gem` build dependency:

```bash
# alongside this repo, e.g. under ~/dev/src/github.com/bash0C7/
git clone https://github.com/bash0C7/swift_gem.git
git clone https://github.com/bash0C7/rb-natural-language-mac.git
cd rb-natural-language-mac
bundle install
bundle exec rake compile
```

`Gemfile` references `swift_gem` via `path: "../swift_gem"` until both gems publish. Once published, this becomes a normal `gem "rb-natural-language-mac"` in your Gemfile.

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
# => 1.0   (Float, roughly -1.0..1.0; nil when no model ships for the language)

NaturalLanguageMac.embedding_dimension("en")
# => 512   (depends on macOS NLEmbedding version)

NaturalLanguageMac.embed_sentence("Today is a fine day.", "en")
# => [0.4472, 0.2692, -0.2569, ...]   (Array<Float>, size == embedding_dimension)

NaturalLanguageMac.contextual_dimension("ja")
# => 512   (NLContextualEmbedding, macOS 14+)

NaturalLanguageMac.embed_contextual("これは日本語の文章です", "ja")
# => [0.1234, -0.0567, ...]   (Array<Float>, mean-pooled token vectors)
```

`detect_language` / `tokenize` / `tag` return a single newline-separated string. `tag` uses tab as the sub-field separator. Whitespace and punctuation are skipped by the tagger. On failure (empty input, OS error) the methods return `""`.

`sentiment_score(text)` returns a document-level sentiment as a `Float` (roughly `-1.0` for very negative to `+1.0` for very positive) from `NLTagger` with the `.sentimentScore` scheme, using `unit: .paragraph` and the auto-detected language. One text in, one score out — split into paragraphs upstream if you want per-paragraph scores. It returns `nil` (deliberately distinct from a genuine neutral `0.0`) on empty input, or when Apple ships no sentiment model for the detected language.

**`sentiment_score` is English-effective only.** Apple ships the sentiment model for a narrow set of languages; empirically on macOS 26.4.1, `NLTagger.availableTagSchemes(for: .paragraph, language:)` includes `Sentiment` for `en` but **not for `ja`** — Japanese text returns `nil` regardless of `setLanguage`. If you need a score for Japanese (or other unshipped languages), the gem leaves that to the caller, by design (see *Preconditions* below). Two practical workarounds:

1. **Pass English text directly.** If you already have an English rendering, score that.
2. **Translate first, then score.** Apple's on-device Translation framework is available via the sibling gem [rb-translation-mac](https://github.com/bash0C7/rb-translation-mac) — translate `ja` → `en` and feed the result to `sentiment_score`:

   ```ruby
   require "natural_language_mac"
   require "translation_mac"

   ja = "これはとても素晴らしい一日でした。本当に楽しかったです。"
   en = TranslationMac.translate(ja, from: "ja", to: "en")
   NaturalLanguageMac.sentiment_score(en.text) if en.success
   # => 1.0   (en.text was "It was a very wonderful day. It was really fun.")
   ```

   Translation is on-device, lossy, and adds helper-subprocess latency, so treat the result as a coarse signal. Apple's English sentiment is itself approximate (neutral and matter-of-fact sentences can score noticeably negative), so do **not** build a strict threshold gate on it without validating against your own text — that is the caller's responsibility (see below).

`embed_sentence(text, language)` returns the sentence embedding from `NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: language))` as an `Array<Float>`. Returns `[]` on empty text, empty language, unsupported language, or when Apple has not shipped a sentence embedding model for the requested language. `embedding_dimension(language)` returns the embedding dimension as `Integer` (or `0` if unavailable).

`embed_contextual(text, language)` (macOS 14+) returns a mean-pooled contextual embedding from `NLContextualEmbedding(language:)`. This is the **only** path that yields Japanese (and many CJK / multilingual) sentence vectors, since `NLEmbedding.sentenceEmbedding` ships only `en` / `it` models. The contextual embedding model uses BERT-style transformer assets bundled with the OS (no extra download); language coverage is much wider. Token-level vectors are averaged in Swift into a single `Array<Float>` of length `contextual_dimension(language)` (typically 512). Returns `[]` on empty text, empty language, unsupported language, or when assets cannot be loaded.

**Apple's sentence embedding language coverage is narrow.** Empirically on macOS 26.4.1 / Apple Silicon, `NLEmbedding.sentenceEmbedding` is non-`nil` only for `en` and `it`; `ja` / `zh-Hans` / `ko` / others return `nil`. The same constraint applies to `wordEmbedding`. If you need sentence embeddings in unsupported languages, consider Apple's `FoundationModels` framework (macOS 26+), a Core ML conversion of a multilingual sentence-transformer, or an external API.

Or open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Preconditions: caller is responsible for input quality

This gem is a **thin pass-through wrapper** around `NLLanguageRecognizer`, `NLTokenizer`, and `NLTagger` with their stock Apple-shipped models. It does no input preprocessing — no encoding fixup, no language hint, no domain customization, no model swap. If the input string is empty or the framework returns no result, the methods return `""`.

Apple's NL framework has known weak spots:

- **Very short text** (`detect_language`) — `NLLanguageRecognizer` is unreliable on inputs shorter than ~10–20 chars. A single word or fragment may pick the wrong language or return `""`. Caller should aggregate context before detecting, or accept low-confidence guesses.
- **Mixed-language text** — only the dominant language is returned. If you need per-segment detection, split into sentences upstream and detect each.
- **Language coverage** — Apple's models cover Latin / CJK / Cyrillic / Arabic well; coverage of Indic, South-East Asian, and African scripts is uneven. Check `NLLanguageRecognizer.dominantLanguage` against your expected set in the caller.
- **Domain-specific tagging** (`tag`) — the lexical-class tagger is trained on general newswire-style text. Code, medical / legal jargon, social-media slang, and OCR'd output may be mis-tagged. There is no way to swap the tagger's model from this gem; if you need a domain model, train upstream and run a different binding.
- **Encoding** — the C bridge expects UTF-8 (Ruby's default). Pre-normalize (e.g. `String#unicode_normalize(:nfc)`) if you mix NFC/NFD inputs and care about consistent tokenization.
- **Empty / whitespace-only input** — returns `""`. The gem does not raise; the caller is expected to validate non-empty input before calling if that matters.

**Detection of these cases is also the caller's job.** All three methods return `""` for "framework returned nothing", "empty input", and "OS error" alike — the gem does not distinguish them. Callers that need branching behavior should branch on `output.empty?` and apply their own fallback (retry with longer context, fall back to a different detector, accept the empty result, etc.).

This gem takes only string input — there is no file path involved, so there is no `Errno::ENOENT` to surface. Path-taking siblings (`rb-vision-mac`, `rb-vision-ocrmac`, `rb-sound-analysis-mac`) raise `Errno::ENOENT` for missing paths; here the analogous unrecoverable case is "non-string input", which Ruby itself enforces via `StringValueCStr` raising `TypeError`.

## Reference: Ruby example

`example.rb` at the repo root demonstrates the core methods end-to-end:

```bash
bundle exec ruby example.rb "The quick brown fox jumps over the lazy dog."
```

`examples/embed_sentence.rb` demonstrates the sentence-embedding API:

```bash
bundle exec ruby examples/embed_sentence.rb "Hello world." "en"
```

## Reference: pure Swift sample

A self-contained Swift script lives at `examples/natural_language_mac.swift` for sanity-checking NaturalLanguage behavior without going through Ruby:

```bash
xcrun swift examples/natural_language_mac.swift "Hello world."
```

Use `xcrun swift` (Xcode toolchain), not bare `swift` from swiftly — swiftly 6.3's interpret mode does not JIT-link Apple system frameworks (NaturalLanguage) and fails at startup with symbol-resolution errors. Xcode's swift uses dyld and works as-is.

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` automatically compiles the Swift Package (`swift build -c release`) and links the C bridge into `lib/natural_language_mac/natural_language_mac.bundle` before running the spec, via `Rake::ExtensionTask`.

To run only the build step: `bundle exec rake compile`.

## License

MIT.
