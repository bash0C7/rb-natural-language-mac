# rb-natural-language-mac

Ruby binding for Apple's Natural Language framework on macOS / Apple Silicon. Calls `NLLanguageRecognizer`, `NLTokenizer`, and `NLTagger` directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute) for the library build. Install via [swiftly](https://www.swift.org/install/macos/).
- Ruby 3.2+, Bundler 4.x
- **Xcode Command Line Tools** only if you want to run `examples/natural_language_mac.swift`. The pure-Swift sample must run under `xcrun swift`; swiftly's 6.3 swift binary cannot JIT-link Apple system frameworks (NaturalLanguage) in interpret mode. The library build itself does not need CLT. Install with `xcode-select --install`.

## Installation

```bash
bundle add rb-natural-language-mac
```

```bash
gem install rb-natural-language-mac
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

NaturalLanguageMac.embedding_dimension("en")
# => 512   (depends on macOS NLEmbedding version)

NaturalLanguageMac.embed_sentence("Today is a fine day.", "en")
# => [0.4472, 0.2692, -0.2569, ...]   (Array<Float>, size == embedding_dimension)
```

`detect_language` / `tokenize` / `tag` return a single newline-separated string. `tag` uses tab as the sub-field separator. Whitespace and punctuation are skipped by the tagger. On failure (empty input, OS error) the methods return `""`.

`embed_sentence(text, language)` returns the sentence embedding from `NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: language))` as an `Array<Float>`. Returns `[]` on empty text, empty language, unsupported language, or when Apple has not shipped a sentence embedding model for the requested language. `embedding_dimension(language)` returns the embedding dimension as `Integer` (or `0` if unavailable).

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

`example.rb` at the repo root demonstrates the three core methods end-to-end:

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
