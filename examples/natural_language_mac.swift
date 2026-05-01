import Foundation
import NaturalLanguage

// Run with: swift examples/natural_language_mac.swift "<text>"

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write("usage: swift examples/natural_language_mac.swift <text>\n".data(using: .utf8)!)
    exit(1)
}

let text = CommandLine.arguments[1]

let recognizer = NLLanguageRecognizer()
recognizer.processString(text)
print("language: \(recognizer.dominantLanguage?.rawValue ?? "")")

let tokenizer = NLTokenizer(unit: .word)
tokenizer.string = text
var tokens: [String] = []
tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
    tokens.append(String(text[range]))
    return true
}
print("tokens: \(tokens)")

let tagger = NLTagger(tagSchemes: [.lexicalClass])
tagger.string = text
print("tags:")
tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                     unit: .word,
                     scheme: .lexicalClass,
                     options: [.omitWhitespace, .omitPunctuation]) { tag, range in
    if let tag = tag {
        print("  \(text[range])\t\(tag.rawValue)")
    }
    return true
}
