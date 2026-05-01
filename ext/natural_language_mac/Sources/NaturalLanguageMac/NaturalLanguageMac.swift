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
