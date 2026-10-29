import Foundation
import NaturalLanguage

private func formatVector(_ vector: [Double]) -> String {
    vector.map { String(format: "%.17g", $0) }.joined(separator: "\n")
}

/// Detects the dominant language of `text` with `NLLanguageRecognizer`.
///
/// ``cDetectLanguage(_:)`` exposes this function to C.
///
/// - Parameter text: The text to analyze.
/// - Returns: The BCP-47 tag of the dominant language, or an empty string when `text` is empty or no language is recognized.
func detectLanguage(text: String) -> String {
    if text.isEmpty { return "" }
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    return recognizer.dominantLanguage?.rawValue ?? ""
}

/// Splits `text` into words with `NLTokenizer`.
///
/// ``cTokenize(_:)`` exposes this function to C.
///
/// - Parameter text: The text to tokenize.
/// - Returns: The word tokens joined by newlines, or an empty string when `text` is empty.
func tokenize(text: String) -> String {
    if text.isEmpty { return "" }
    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = text
    return tokenizer.tokens(for: text.startIndex..<text.endIndex)
        .map { String(text[$0]) }
        .joined(separator: "\n")
}

/// Tags each word of `text` with its lexical class using `NLTagger`.
///
/// Whitespace and punctuation are omitted. ``cTag(_:)`` exposes this function to C.
///
/// - Parameter text: The text to tag.
/// - Returns: One `token\ttag` line per word, or an empty string when `text` is empty.
func tag(text: String) -> String {
    if text.isEmpty { return "" }
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text
    return tagger.tags(in: text.startIndex..<text.endIndex,
                       unit: .word,
                       scheme: .lexicalClass,
                       options: [.omitWhitespace, .omitPunctuation])
        .compactMap { tag, range in tag.map { "\(text[range])\t\($0.rawValue)" } }
        .joined(separator: "\n")
}

/// Scores the sentiment of `text` as one paragraph with the `.sentimentScore` scheme of `NLTagger`.
///
/// The language is detected automatically. ``cSentimentScore(_:)`` exposes this function to C.
///
/// - Parameter text: The text to score.
/// - Returns: The score, roughly from `-1.0` to `1.0`, or an empty string when `text` is empty or no sentiment model ships for the detected language.
func sentimentScore(text: String) -> String {
    if text.isEmpty { return "" }
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    guard let raw = sentiment?.rawValue, let score = Double(raw) else { return "" }
    return String(format: "%.17g", score)
}

/// Computes the sentence embedding of `text` with `NLEmbedding.sentenceEmbedding(for:)`.
///
/// ``cEmbedSentence(_:_:)`` exposes this function to C.
///
/// - Parameters:
///   - text: The sentence to embed.
///   - language: The BCP-47 tag of the embedding language.
/// - Returns: The vector components joined by newlines, or an empty string when an argument is empty or no sentence embedding ships for `language`.
func embedSentence(text: String, language: String) -> String {
    if text.isEmpty || language.isEmpty { return "" }
    guard let vector = NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: language))?.vector(for: text) else {
        return ""
    }
    return formatVector(vector)
}

/// Returns the dimension of `NLEmbedding.sentenceEmbedding(for:)` for `language`.
///
/// ``cEmbeddingDimension(_:)`` exposes this function to C.
///
/// - Parameter language: The BCP-47 tag of the embedding language.
/// - Returns: The dimension in decimal, or an empty string when `language` is empty or no sentence embedding ships for it.
func embeddingDimension(language: String) -> String {
    if language.isEmpty { return "" }
    guard let embedding = NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: language)) else { return "" }
    return String(embedding.dimension)
}

/// Computes a sentence vector of `text` by mean-pooling the token vectors of `NLContextualEmbedding`.
///
/// ``cEmbedContextual(_:_:)`` exposes this function to C.
///
/// - Parameters:
///   - text: The sentence to embed.
///   - language: The BCP-47 tag of the embedding language.
/// - Returns: The mean vector components joined by newlines, or an empty string when an argument is empty, no contextual embedding supports `language`, or its assets cannot be loaded.
func embedContextual(text: String, language: String) -> String {
    if text.isEmpty || language.isEmpty { return "" }
    let nlLanguage = NLLanguage(rawValue: language)
    guard let embedding = NLContextualEmbedding(language: nlLanguage) else { return "" }
    let result: NLContextualEmbeddingResult
    do {
        try embedding.load()
        result = try embedding.embeddingResult(for: text, language: nlLanguage)
    } catch {
        return ""
    }

    var sum = [Double](repeating: 0, count: embedding.dimension)
    var count = 0
    result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, _ in
        if vector.count == sum.count {
            for (i, value) in vector.enumerated() {
                sum[i] += value
            }
            count += 1
        }
        return true
    }
    if count == 0 { return "" }
    return formatVector(sum.map { $0 / Double(count) })
}

/// Returns the dimension of `NLContextualEmbedding` for `language`.
///
/// ``cContextualDimension(_:)`` exposes this function to C.
///
/// - Parameter language: The BCP-47 tag of the embedding language.
/// - Returns: The dimension in decimal, or an empty string when `language` is empty or no contextual embedding supports it.
func contextualDimension(language: String) -> String {
    if language.isEmpty { return "" }
    guard let embedding = NLContextualEmbedding(language: NLLanguage(rawValue: language)) else { return "" }
    return String(embedding.dimension)
}
