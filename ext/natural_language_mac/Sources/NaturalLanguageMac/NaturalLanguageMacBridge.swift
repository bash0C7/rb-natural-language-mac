import Foundation

@_cdecl("natural_language_mac_perform")
public func natural_language_mac_perform(_ input: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: input)
    let result = natural_language_mac_perform(s)
    return strdup(result)!
}

@_cdecl("natural_language_mac_free")
public func natural_language_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
