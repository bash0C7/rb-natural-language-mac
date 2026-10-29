import Foundation
import NaturalLanguage

guard let text = CommandLine.arguments.dropFirst().first else {
    FileHandle.standardError.write(Data("usage: xcrun swift examples/natural_language_mac.swift <text>\n".utf8))
    exit(1)
}

let recognizer = NLLanguageRecognizer()
recognizer.processString(text)
print("language: \(recognizer.dominantLanguage?.rawValue ?? "")")

let tokenizer = NLTokenizer(unit: .word)
tokenizer.string = text
print("tokens: \(tokenizer.tokens(for: text.startIndex..<text.endIndex).map { String(text[$0]) })")

let tagger = NLTagger(tagSchemes: [.lexicalClass])
tagger.string = text
print("tags:")
for (tag, range) in tagger.tags(in: text.startIndex..<text.endIndex,
                                unit: .word,
                                scheme: .lexicalClass,
                                options: [.omitWhitespace, .omitPunctuation]) {
    if let tag {
        print("  \(text[range])\t\(tag.rawValue)")
    }
}
