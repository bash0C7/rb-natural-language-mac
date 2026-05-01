#include <ruby.h>
#include "natural_language_mac.h"

static VALUE call_swift_string(char *(*fn)(const char *), VALUE input) {
    const char *c_input = StringValueCStr(input);
    char *result = fn(c_input);
    if (result == NULL) {
        return rb_utf8_str_new_cstr("");
    }
    VALUE rb_result = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);
    return rb_result;
}

static VALUE rb_natural_language_mac_detect_language(VALUE self, VALUE text) {
    return call_swift_string(natural_language_mac_detect_language, text);
}

static VALUE rb_natural_language_mac_tokenize(VALUE self, VALUE text) {
    return call_swift_string(natural_language_mac_tokenize, text);
}

static VALUE rb_natural_language_mac_tag(VALUE self, VALUE text) {
    return call_swift_string(natural_language_mac_tag, text);
}

void Init_natural_language_mac(void) {
    VALUE module = rb_define_module("NaturalLanguageMac");
    rb_define_singleton_method(module, "detect_language", rb_natural_language_mac_detect_language, 1);
    rb_define_singleton_method(module, "tokenize", rb_natural_language_mac_tokenize, 1);
    rb_define_singleton_method(module, "tag", rb_natural_language_mac_tag, 1);
}
