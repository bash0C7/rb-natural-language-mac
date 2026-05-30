#include <ruby.h>
#include "NaturalLanguageMac-Swift.h"

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

static VALUE rb_natural_language_mac_sentiment_score(VALUE self, VALUE text) {
    const char *c_text = StringValueCStr(text);
    char *result = natural_language_mac_sentiment_score(c_text);
    if (result == NULL || result[0] == '\0') {
        if (result) natural_language_mac_free(result);
        return Qnil;
    }
    VALUE rb_str = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);
    return rb_funcall(rb_str, rb_intern("to_f"), 0);
}

static VALUE rb_natural_language_mac_embed_sentence(VALUE self, VALUE text, VALUE language) {
    const char *c_text = StringValueCStr(text);
    const char *c_language = StringValueCStr(language);
    char *result = natural_language_mac_embed_sentence(c_text, c_language);
    if (result == NULL || result[0] == '\0') {
        if (result) natural_language_mac_free(result);
        return rb_ary_new();
    }
    VALUE rb_str = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);

    VALUE separator = rb_str_new_cstr("\n");
    VALUE split = rb_funcall(rb_str, rb_intern("split"), 1, separator);
    long n = RARRAY_LEN(split);
    VALUE ary = rb_ary_new_capa(n);
    for (long i = 0; i < n; i++) {
        VALUE elem = RARRAY_AREF(split, i);
        VALUE flt = rb_funcall(elem, rb_intern("to_f"), 0);
        rb_ary_push(ary, flt);
    }
    return ary;
}

static VALUE rb_natural_language_mac_embedding_dimension(VALUE self, VALUE language) {
    const char *c_language = StringValueCStr(language);
    char *result = natural_language_mac_embedding_dimension(c_language);
    if (result == NULL || result[0] == '\0') {
        if (result) natural_language_mac_free(result);
        return INT2NUM(0);
    }
    VALUE rb_str = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);
    return rb_funcall(rb_str, rb_intern("to_i"), 0);
}

static VALUE rb_natural_language_mac_embed_contextual(VALUE self, VALUE text, VALUE language) {
    const char *c_text = StringValueCStr(text);
    const char *c_language = StringValueCStr(language);
    char *result = natural_language_mac_embed_contextual(c_text, c_language);
    if (result == NULL || result[0] == '\0') {
        if (result) natural_language_mac_free(result);
        return rb_ary_new();
    }
    VALUE rb_str = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);

    VALUE separator = rb_str_new_cstr("\n");
    VALUE split = rb_funcall(rb_str, rb_intern("split"), 1, separator);
    long n = RARRAY_LEN(split);
    VALUE ary = rb_ary_new_capa(n);
    for (long i = 0; i < n; i++) {
        VALUE elem = RARRAY_AREF(split, i);
        VALUE flt = rb_funcall(elem, rb_intern("to_f"), 0);
        rb_ary_push(ary, flt);
    }
    return ary;
}

static VALUE rb_natural_language_mac_contextual_dimension(VALUE self, VALUE language) {
    const char *c_language = StringValueCStr(language);
    char *result = natural_language_mac_contextual_dimension(c_language);
    if (result == NULL || result[0] == '\0') {
        if (result) natural_language_mac_free(result);
        return INT2NUM(0);
    }
    VALUE rb_str = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);
    return rb_funcall(rb_str, rb_intern("to_i"), 0);
}

void Init_natural_language_mac(void) {
    VALUE module = rb_define_module("NaturalLanguageMac");
    rb_define_singleton_method(module, "detect_language", rb_natural_language_mac_detect_language, 1);
    rb_define_singleton_method(module, "tokenize", rb_natural_language_mac_tokenize, 1);
    rb_define_singleton_method(module, "tag", rb_natural_language_mac_tag, 1);
    rb_define_singleton_method(module, "sentiment_score", rb_natural_language_mac_sentiment_score, 1);
    rb_define_singleton_method(module, "embed_sentence", rb_natural_language_mac_embed_sentence, 2);
    rb_define_singleton_method(module, "embedding_dimension", rb_natural_language_mac_embedding_dimension, 1);
    rb_define_singleton_method(module, "embed_contextual", rb_natural_language_mac_embed_contextual, 2);
    rb_define_singleton_method(module, "contextual_dimension", rb_natural_language_mac_contextual_dimension, 1);
}
