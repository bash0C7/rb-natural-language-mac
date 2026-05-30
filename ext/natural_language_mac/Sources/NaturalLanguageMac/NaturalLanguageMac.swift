import Foundation
import NaturalLanguage

func performDetectLanguage(text: String) -> String {
    if text.isEmpty { return "" }
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    guard let lang = recognizer.dominantLanguage else { return "" }
    return lang.rawValue
}

func performTokenize(text: String) -> String {
    if text.isEmpty { return "" }
    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = text
    var tokens: [String] = []
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
        tokens.append(String(text[range]))
        return true
    }
    return tokens.joined(separator: "\n")
}

func performTag(text: String) -> String {
    if text.isEmpty { return "" }
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text
    var pairs: [String] = []
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                         unit: .word,
                         scheme: .lexicalClass,
                         options: options) { tag, range in
        if let tag = tag {
            let token = String(text[range])
            pairs.append("\(token)\t\(tag.rawValue)")
        }
        return true
    }
    return pairs.joined(separator: "\n")
}

func performSentimentScore(text: String) -> String {
    if text.isEmpty { return "" }
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    guard let raw = sentiment?.rawValue, let score = Double(raw) else { return "" }
    return String(format: "%.17g", score)
}

func performEmbedSentence(text: String, language: String) -> String {
    if text.isEmpty || language.isEmpty { return "" }
    let nlLanguage = NLLanguage(rawValue: language)
    guard let embedding = NLEmbedding.sentenceEmbedding(for: nlLanguage) else {
        return ""
    }
    guard let vector = embedding.vector(for: text) else {
        return ""
    }
    return vector.map { String(format: "%.17g", $0) }.joined(separator: "\n")
}

func performEmbeddingDimension(language: String) -> String {
    if language.isEmpty { return "" }
    let nlLanguage = NLLanguage(rawValue: language)
    guard let embedding = NLEmbedding.sentenceEmbedding(for: nlLanguage) else {
        return ""
    }
    return String(embedding.dimension)
}

@available(macOS 14, *)
func performEmbedContextual(text: String, language: String) -> String {
    if text.isEmpty || language.isEmpty { return "" }
    let nlLanguage = NLLanguage(rawValue: language)
    guard let embedding = NLContextualEmbedding(language: nlLanguage) else {
        return ""
    }
    if !embedding.hasAvailableAssets {
        do {
            try embedding.load()
        } catch {
            return ""
        }
    }
    let result: NLContextualEmbeddingResult
    do {
        result = try embedding.embeddingResult(for: text, language: nlLanguage)
    } catch {
        return ""
    }

    let dim = embedding.dimension
    var sum = [Double](repeating: 0.0, count: dim)
    var count: Int = 0
    result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, _ in
        if vector.count == dim {
            for i in 0..<dim {
                sum[i] += vector[i]
            }
            count += 1
        }
        return true
    }
    if count == 0 { return "" }
    let mean = sum.map { $0 / Double(count) }
    return mean.map { String(format: "%.17g", $0) }.joined(separator: "\n")
}

@available(macOS 14, *)
func performContextualDimension(language: String) -> String {
    if language.isEmpty { return "" }
    let nlLanguage = NLLanguage(rawValue: language)
    guard let embedding = NLContextualEmbedding(language: nlLanguage) else {
        return ""
    }
    return String(embedding.dimension)
}
