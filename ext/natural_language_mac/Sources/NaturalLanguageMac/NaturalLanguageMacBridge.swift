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
public func natural_language_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
