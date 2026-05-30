import Foundation

@c
public func natural_language_mac_detect_language(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performDetectLanguage(text: s))!
}

@c
public func natural_language_mac_tokenize(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performTokenize(text: s))!
}

@c
public func natural_language_mac_tag(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performTag(text: s))!
}

@c
public func natural_language_mac_sentiment_score(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performSentimentScore(text: s))!
}

@c
public func natural_language_mac_embed_sentence(_ text: UnsafePointer<CChar>, _ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let t = String(cString: text)
    let l = String(cString: language)
    return strdup(performEmbedSentence(text: t, language: l))!
}

@c
public func natural_language_mac_embedding_dimension(_ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let l = String(cString: language)
    return strdup(performEmbeddingDimension(language: l))!
}

@c
public func natural_language_mac_embed_contextual(_ text: UnsafePointer<CChar>, _ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let t = String(cString: text)
    let l = String(cString: language)
    if #available(macOS 14, *) {
        return strdup(performEmbedContextual(text: t, language: l))!
    } else {
        return strdup("")!
    }
}

@c
public func natural_language_mac_contextual_dimension(_ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let l = String(cString: language)
    if #available(macOS 14, *) {
        return strdup(performContextualDimension(language: l))!
    } else {
        return strdup("")!
    }
}

@c
public func natural_language_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
