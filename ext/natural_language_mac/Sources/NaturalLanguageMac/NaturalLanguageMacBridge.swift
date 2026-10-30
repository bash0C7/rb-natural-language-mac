import Foundation

/// Calls `detectLanguage(text:)` from C as `natural_language_mac_detect_language`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter text: A NUL-terminated UTF-8 string.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_detect_language)
public func cDetectLanguage(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(detectLanguage(text: String(cString: text)))!
}

/// Calls `tokenize(text:)` from C as `natural_language_mac_tokenize`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter text: A NUL-terminated UTF-8 string.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_tokenize)
public func cTokenize(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(tokenize(text: String(cString: text)))!
}

/// Calls `tag(text:)` from C as `natural_language_mac_tag`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter text: A NUL-terminated UTF-8 string.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_tag)
public func cTag(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(tag(text: String(cString: text)))!
}

/// Calls `sentimentScore(text:)` from C as `natural_language_mac_sentiment_score`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter text: A NUL-terminated UTF-8 string.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_sentiment_score)
public func cSentimentScore(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(sentimentScore(text: String(cString: text)))!
}

/// Calls `embedSentence(text:language:)` from C as `natural_language_mac_embed_sentence`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameters:
///   - text: A NUL-terminated UTF-8 string.
///   - language: A NUL-terminated UTF-8 BCP-47 tag.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_embed_sentence)
public func cEmbedSentence(_ text: UnsafePointer<CChar>, _ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(embedSentence(text: String(cString: text), language: String(cString: language)))!
}

/// Calls `embeddingDimension(language:)` from C as `natural_language_mac_embedding_dimension`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter language: A NUL-terminated UTF-8 BCP-47 tag.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_embedding_dimension)
public func cEmbeddingDimension(_ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(embeddingDimension(language: String(cString: language)))!
}

/// Calls `embedContextual(text:language:)` from C as `natural_language_mac_embed_contextual`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameters:
///   - text: A NUL-terminated UTF-8 string.
///   - language: A NUL-terminated UTF-8 BCP-47 tag.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_embed_contextual)
public func cEmbedContextual(_ text: UnsafePointer<CChar>, _ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(embedContextual(text: String(cString: text), language: String(cString: language)))!
}

/// Calls `contextualDimension(language:)` from C as `natural_language_mac_contextual_dimension`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter language: A NUL-terminated UTF-8 BCP-47 tag.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(natural_language_mac_contextual_dimension)
public func cContextualDimension(_ language: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    strdup(contextualDimension(language: String(cString: language)))!
}

/// Releases a buffer returned by any `natural_language_mac_*` function, exposed to C as `natural_language_mac_free`.
///
/// The caller owns every buffer those functions return and must pass it to this function exactly once.
///
/// - Parameter ptr: The buffer to release, or `nil`.
@c(natural_language_mac_free)
public func cFree(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
