# CLAUDE.md — rb-natural-language-mac

## Position

Ruby native binding for Apple's Natural Language framework on macOS. Sibling of `rb-vision-ocrmac`, built on the same `bash0C7/swift_gem` scaffold. Exposes language detection, tokenization, and linguistic tagging as singleton methods on `NaturalLanguageMac`.

## Core design principles

1. Thin wrapper. Pass-through Natural Language API. One text → one string (newline separator, optional `\t` for sub-fields). Option expansion (custom NLEmbedding, NLModel, sentiment, etc.) is intentionally not added until needed.
2. Fixed defaults: tokenizer unit `.word`; tagger scheme `.lexicalClass`. Changes go through new API methods; never break existing behavior.
3. Synchronous calls. NaturalLanguage APIs are not async, so no semaphore/timeout. Failure (empty input, OS error, framework returned nothing) → empty string. Does not raise exceptions. (Unlike sibling path-taking gems, there is no file involved here, so no `Errno::ENOENT` surface.)
4. C bridge string handoff. Swift allocates with `strdup`, C frees via `natural_language_mac_free`. Bridge function signatures fixed at `UnsafePointer<CChar>` ↔ `UnsafeMutablePointer<CChar>`.
5. Scaffold parity. `swift_gem new rb-natural-language-mac` produces a skeleton whose only diffs against this repo are the implementation body, fixtures, and build artifacts.

## Architecture

```
[caller (Ruby)]
  │
  │   NaturalLanguageMac.{detect_language,tokenize,tag}(text) → String
  ▼
lib/natural_language_mac.rb            ← requires the ext + module declaration
  │
  ▼
ext/natural_language_mac/natural_language_mac.c   ← rb_define_singleton_method
  │
  │   natural_language_mac_{detect_language,tokenize,tag}(c_text)
  ▼
ext/natural_language_mac/Sources/NaturalLanguageMac/NaturalLanguageMacBridge.swift   ← @c (SE-0495)
  │
  ▼
ext/natural_language_mac/Sources/NaturalLanguageMac/NaturalLanguageMac.swift   ← NLLanguageRecognizer / NLTokenizer / NLTagger
  │
  ▼
[Apple NaturalLanguage framework]
```

## Public API

| Method | Returns | Notes |
|---|---|---|
| `NaturalLanguageMac.detect_language(text)` | BCP-47 tag string (`"ja"`, `"en"`…) or `""` | NLLanguageRecognizer. Most likely language only |
| `NaturalLanguageMac.tokenize(text)` | newline-separated tokens | NLTokenizer with `.word` unit |
| `NaturalLanguageMac.tag(text)` | newline-separated `"token\ttag"` | NLTagger with `.lexicalClass` scheme; omits whitespace and punctuation |

## Module boundaries

| Layer | Responsibility |
|---|---|
| `lib/natural_language_mac.rb` | `require_relative` to load the .bundle; host of `module NaturalLanguageMac` |
| `ext/natural_language_mac/natural_language_mac.c` | `Init_natural_language_mac` exposes the three singleton methods; copies Swift-returned `char*` into a Ruby UTF-8 String, then calls `natural_language_mac_free` |
| `NaturalLanguageMacBridge.swift` | C ABI exports via `@c` (SE-0495). Calls Swift implementations and returns C strings via `strdup` |
| `NaturalLanguageMac.swift` | Real implementation: `NLLanguageRecognizer.dominantLanguage`, `NLTokenizer(unit:.word)`, `NLTagger(tagSchemes:[.lexicalClass])` |
| `ext/natural_language_mac/extconf.rb` | `SwiftGem::Mkmf.create_swift_makefile("natural_language_mac/natural_language_mac", package: "NaturalLanguageMac", source_dir: __dir__)` |
| `examples/natural_language_mac.swift` | Pure-Swift sample script: `xcrun swift examples/natural_language_mac.swift "<text>"`. Ruby-free, kept as a NaturalLanguage-behavior reference. Must use `xcrun swift` (Xcode toolchain) — swiftly 6.3's interpret mode cannot JIT-link Apple system frameworks |
| `Rakefile` | `Rake::ExtensionTask("natural_language_mac")` + `task test: :compile`. `task console: :compile` for IRB |

## Build flow

`bundle exec rake test` in one shot: same as `rb-vision-ocrmac`. See its CLAUDE.md and `swift_gem`'s CLAUDE.md.

## Usage / why no CLI

Library only — same rationale as `rb-vision-ocrmac`. Interactive checks via `bundle exec rake console`. `examples/natural_language_mac.swift` for pure-Swift Ruby-free verification of NaturalLanguage behavior.

## TDD discipline

t-wada style RED → GREEN → REFACTOR independent commits. test-unit. Inline-string fixtures (no binary fixture file needed).

## Related projects

- `~/dev/src/github.com/bash0C7/swift_gem` — scaffold/Mkmf framework
- `~/dev/src/github.com/bash0C7/rb-vision-ocrmac` — sibling reference implementation

## Environment requirements

macOS 12+, Apple Silicon, Swift 6.3+ (SE-0495 `@c` requires 6.3; install via [swiftly](https://www.swift.org/install/macos/)), Ruby 3.2+, bundler 4.x, rake-compiler 1.2+. `Gemfile` references swift_gem via `path: "../swift_gem"` until publish. `Gemfile.lock` not git-tracked.

Xcode Command Line Tools required only for running `examples/natural_language_mac.swift` via `xcrun swift` — swiftly's 6.3 swift binary has broken Apple-framework JIT linkage in interpret mode (verified across the family: SDKROOT, -F, -Xlinker, -sdk all fail). The library build itself does not need CLT. example.swift does not use SE-0495 `@c`, so CLT's older swift (6.2.4) suffices. Install with `xcode-select --install`.

## Prohibitions

- No Python source
- Do not git-track `Gemfile.lock`
- Do not add caching, normalization, or post-processing of NL results — leave that to callers
- Do not promise thread safety for concurrent calls — add a lock if needed
- Commit messages in English, conventional commits style
- `.claude/` is committed
