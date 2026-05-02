# rb-natural-language-mac

Ruby binding for Apple's Natural Language framework on macOS / Apple Silicon. Calls `NLLanguageRecognizer`, `NLTokenizer`, and `NLTagger` directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute). Install via [swiftly](https://www.swift.org/install/macos/) — Xcode not required.
- Ruby 3.2+, Bundler 4.x

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
```

All three methods return a single newline-separated string. `tag` uses tab as the sub-field separator. Whitespace and punctuation are skipped by the tagger. On failure (empty input, OS error) the methods return `""`.

Or open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Reference: Ruby example

`example.rb` at the repo root demonstrates the three methods end-to-end:

```bash
bundle exec ruby example.rb "The quick brown fox jumps over the lazy dog."
```

## Reference: pure Swift sample

A self-contained Swift script lives at `examples/natural_language_mac.swift` for sanity-checking NaturalLanguage behavior without going through Ruby:

```bash
swift examples/natural_language_mac.swift "Hello world."
```

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` automatically compiles the Swift Package (`swift build -c release`) and links the C bridge into `lib/natural_language_mac/natural_language_mac.bundle` before running the spec, via `Rake::ExtensionTask`.

To run only the build step: `bundle exec rake compile`.

## License

MIT.
