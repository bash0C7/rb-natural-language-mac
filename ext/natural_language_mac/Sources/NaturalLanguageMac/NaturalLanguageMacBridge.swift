import Foundation

@_cdecl("natural_language_mac_detect_language")
public func natural_language_mac_detect_language(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performDetectLanguage(text: s))!
}

@_cdecl("natural_language_mac_tokenize")
public func natural_language_mac_tokenize(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performTokenize(text: s))!
}

@_cdecl("natural_language_mac_tag")
public func natural_language_mac_tag(_ text: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: text)
    return strdup(performTag(text: s))!
}

@_cdecl("natural_language_mac_free")
public func natural_language_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
