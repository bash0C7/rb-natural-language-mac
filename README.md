# rb-natural-language-mac

Ruby binding for Apple's Natural Language framework on macOS. Wraps `NLLanguageRecognizer`, `NLTokenizer`, and `NLTagger` as Ruby singleton methods.

Built on top of [swift_gem](https://github.com/bash0C7/swift_gem). macOS / Apple Silicon only.

## Usage

```ruby
require "natural_language_mac"

NaturalLanguageMac.detect_language("This is English.")
# => "en"

NaturalLanguageMac.detect_language("これは日本語です。")
# => "ja"

NaturalLanguageMac.tokenize("Hello world, this is a test.")
# => "Hello\nworld\nthis\nis\na\ntest"

NaturalLanguageMac.tag("The quick brown fox jumps.")
# => "The\tDeterminer\nquick\tAdjective\nbrown\tAdjective\nfox\tNoun\njumps\tVerb"
```

All three methods return a single newline-separated string. `tag` uses tab as the sub-field separator. Whitespace and punctuation are skipped by the tagger.

On failure (empty input, OS error) the methods return `""`.

## Reference Swift example

```bash
swift examples/natural_language_mac.swift "Hello world."
```

## Development

```bash
bundle install
bundle exec rake test
```

## License

MIT.
