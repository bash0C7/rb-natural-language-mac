# CLAUDE.md — rb-natural-language-mac

## Position

Ruby native binding for Apple's Natural Language framework on macOS, built on the `bash0C7/swift_gem` scaffold. Exposes language detection, tokenization, linguistic tagging, sentiment scoring, and sentence/contextual embeddings as singleton methods on `NaturalLanguageMac`. Sibling of `rb-vision-mac`.

## Core design principles

1. Thin wrapper. Pass-through Natural Language API. Text results are one newline-separated string, with `\t` for sub-fields. Option expansion (custom NLEmbedding, NLModel, etc.) waits until needed.
2. Fixed defaults: tokenizer unit `.word`; tagger scheme `.lexicalClass`; sentiment `unit: .paragraph` with the detected language. Changes go through new API methods; existing behavior stays.
3. Synchronous calls. The NaturalLanguage APIs used here are synchronous, so there is no semaphore or timeout. Failure (empty input, framework returned nothing, no model for the language) → empty value (`""`, `nil`, `[]`, `0`). No exceptions besides Ruby's own `TypeError` for non-string arguments.
4. C bridge string handoff. Each method has its own `@c(<c_name>)` (SE-0495) function and a single shared `cFree` exported as `natural_language_mac_free`. Signatures are fixed at `UnsafePointer<CChar>` → `UnsafeMutablePointer<CChar>`. The C side converts the string to `Float` / `Integer` / `Array<Float>` where the method returns one.
5. Scaffold parity. `bundle exec rake "new[rb-natural-language-mac,<dir>]"` in swift_gem produces a skeleton whose only diffs against this repo are the implementation body, `sig/` contents, example scripts, tests, docs, gemspec summary and description, and build artifacts.

## Architecture

```
[caller (Ruby)]
  │
  │   NaturalLanguageMac.<method>(...) → String / Float / Integer / Array<Float>
  ▼
lib/natural_language_mac.rb            ← requires the ext + module declaration
  │
  ▼
ext/natural_language_mac/natural_language_mac.c   ← rb_define_singleton_method, string → Ruby value
  │
  │   natural_language_mac_<method>(c_text, ...)
  ▼
ext/natural_language_mac/Sources/NaturalLanguageMac/NaturalLanguageMacBridge.swift   ← @c(name) (SE-0495)
  │
  ▼
ext/natural_language_mac/Sources/NaturalLanguageMac/NaturalLanguageMac.swift   ← NLLanguageRecognizer / NLTokenizer / NLTagger / NLEmbedding / NLContextualEmbedding
  │
  ▼
[Apple NaturalLanguage framework]
```

## Public API

| Method | Returns | Notes |
|---|---|---|
| `NaturalLanguageMac.detect_language(text)` | BCP-47 tag string (`"ja"`, `"en"`…) or `""` | `NLLanguageRecognizer.dominantLanguage` |
| `NaturalLanguageMac.tokenize(text)` | newline-separated tokens | `NLTokenizer(unit: .word)` |
| `NaturalLanguageMac.tag(text)` | newline-separated `"token\ttag"` | `NLTagger` with `.lexicalClass`; omits whitespace and punctuation |
| `NaturalLanguageMac.sentiment_score(text)` | `Float` (roughly `-1.0..1.0`) or `nil` | `NLTagger` with `.sentimentScore`, `unit: .paragraph`. `nil` on empty text or when no sentiment model ships for the detected language (Japanese has none). `0.0` is a valid neutral score |
| `NaturalLanguageMac.embed_sentence(text, language)` | `Array<Float>` (`size == embedding_dimension(language)`) or `[]` | `NLEmbedding.sentenceEmbedding(for:)`. Ships for Latin-script languages such as `en`, `fr`, `de`, `es`, `it`; not for `ja`, `zh-Hans`, `ko` |
| `NaturalLanguageMac.embedding_dimension(language)` | `Integer` or `0` | Dimension of `NLEmbedding.sentenceEmbedding(for:)` |
| `NaturalLanguageMac.embed_contextual(text, language)` | `Array<Float>` (mean-pooled, `size == contextual_dimension(language)`) or `[]` | `NLContextualEmbedding(language:)` token vectors averaged in Swift. The path to Japanese, Chinese, and Korean sentence vectors. `[]` when the OTA model assets are not on the device; the gem does not request them |
| `NaturalLanguageMac.contextual_dimension(language)` | `Integer` or `0` | Dimension of `NLContextualEmbedding(language:)` |

Signatures and their documentation live in `sig/natural_language_mac.rbs`.

## Module boundaries

| Layer | Responsibility |
|---|---|
| `lib/natural_language_mac.rb` | `require_relative` to load the .bundle; host of `module NaturalLanguageMac` |
| `sig/natural_language_mac.rbs` | RBS for `VERSION`, `Error`, and every singleton method |
| `ext/natural_language_mac/natural_language_mac.c` | `Init_natural_language_mac` exposes the singleton methods; copies the Swift-returned `char*` into a Ruby UTF-8 String, calls `natural_language_mac_free`, then converts to `Float` / `Integer` / `Array<Float>` where needed |
| `NaturalLanguageMacBridge.swift` | C ABI exports via `@c(name)`. Calls the Swift implementations and returns C strings via `strdup` |
| `NaturalLanguageMac.swift` | Real implementation over `NLLanguageRecognizer`, `NLTokenizer`, `NLTagger`, `NLEmbedding`, `NLContextualEmbedding` |
| `ext/natural_language_mac/extconf.rb` | `require_relative "swift_mkmf"` + `SwiftGem::Mkmf.create_swift_makefile("natural_language_mac/natural_language_mac", package: "NaturalLanguageMac", source_dir: __dir__)` |
| `ext/natural_language_mac/swift_mkmf.rb` | Vendored copy of swift_gem's `lib/swift_gem/mkmf.rb`, kept identical |
| `examples/natural_language_mac.swift` | Ruby-free NaturalLanguage sample: `xcrun swift examples/natural_language_mac.swift "<text>"` |
| `example.rb`, `examples/*.rb` | Ruby samples: core methods, sentence embedding, sentiment with the translation workaround |
| `Rakefile` | `task :swift` + `task compile: :swift` before `Rake::ExtensionTask("natural_language_mac")`; `task :rbs`; `task test: %i[rbs compile]`; `task console: :compile` |

## Build flow

`bundle exec rake test` validates the RBS, builds, and tests in one shot. `xcrun swift build -c release --package-path ext/natural_language_mac` writes `NaturalLanguageMac-Swift.h` under `ext/natural_language_mac/.build/out/Intermediates.noindex/GeneratedModuleMaps/` (added with `-I`) and the dylib under `ext/natural_language_mac/.build/release`.

## Usage / why no CLI

Library only, same as `rb-vision-mac`. Interactive checks via `bundle exec rake console`.

## TDD discipline

t-wada style RED → GREEN → REFACTOR independent commits. test-unit. Inline-string fixtures. Tests call the real framework; only the contextual-embedding tests omit themselves when the model assets are not on the device.

## Related projects

- `~/dev/src/github.com/bash0C7/swift_gem` — scaffold/Mkmf framework
- `~/dev/src/github.com/bash0C7/rb-vision-mac` — sibling built on the same scaffold
- `~/dev/src/github.com/bash0C7/rb-translation-mac` — used by `examples/sentiment_score.rb` for the Japanese sentiment workaround

## Environment requirements

macOS 27+, Apple Silicon, Xcode 27 (Swift 6.4, builds run `xcrun swift`), Ruby 4.0+, bundler 4.x, rake-compiler 1.2+. `Gemfile.lock` is not git-tracked.

## Prohibitions

- No Python source
- No code comments. Swift is documented with DocC (`///`, `- Parameter`, `- Returns`, ``` ``symbol`` ``` links); Ruby is documented with `#` comments above declarations in `sig/natural_language_mac.rbs`. History goes in commit messages
- Do not hand-edit `ext/natural_language_mac/swift_mkmf.rb`; re-copy it from swift_gem
- Do not git-track `Gemfile.lock`
- Do not add caching, normalization, or post-processing of NL results — leave that to callers
- Do not promise thread safety for concurrent calls — add a lock if needed
- Commit messages in English, conventional commits style
- `.claude/` is committed
