#include <ruby.h>
#include "NaturalLanguageMac-Swift.h"

static VALUE take_string(char *result) {
    VALUE rb_result = rb_utf8_str_new_cstr(result);
    natural_language_mac_free(result);
    return rb_result;
}

static VALUE to_float_array(VALUE lines) {
    VALUE split = rb_funcall(lines, rb_intern("split"), 1, rb_str_new_cstr("\n"));
    long n = RARRAY_LEN(split);
    VALUE ary = rb_ary_new_capa(n);
    for (long i = 0; i < n; i++) {
        rb_ary_push(ary, rb_funcall(RARRAY_AREF(split, i), rb_intern("to_f"), 0));
    }
    return ary;
}

static VALUE rb_natural_language_mac_detect_language(VALUE self, VALUE text) {
    return take_string(natural_language_mac_detect_language(StringValueCStr(text)));
}

static VALUE rb_natural_language_mac_tokenize(VALUE self, VALUE text) {
    return take_string(natural_language_mac_tokenize(StringValueCStr(text)));
}

static VALUE rb_natural_language_mac_tag(VALUE self, VALUE text) {
    return take_string(natural_language_mac_tag(StringValueCStr(text)));
}

static VALUE rb_natural_language_mac_sentiment_score(VALUE self, VALUE text) {
    VALUE score = take_string(natural_language_mac_sentiment_score(StringValueCStr(text)));
    return RSTRING_LEN(score) == 0 ? Qnil : rb_funcall(score, rb_intern("to_f"), 0);
}

static VALUE rb_natural_language_mac_embed_sentence(VALUE self, VALUE text, VALUE language) {
    const char *c_text = StringValueCStr(text);
    const char *c_language = StringValueCStr(language);
    return to_float_array(take_string(natural_language_mac_embed_sentence(c_text, c_language)));
}

static VALUE rb_natural_language_mac_embedding_dimension(VALUE self, VALUE language) {
    VALUE dimension = take_string(natural_language_mac_embedding_dimension(StringValueCStr(language)));
    return rb_funcall(dimension, rb_intern("to_i"), 0);
}

static VALUE rb_natural_language_mac_embed_contextual(VALUE self, VALUE text, VALUE language) {
    const char *c_text = StringValueCStr(text);
    const char *c_language = StringValueCStr(language);
    return to_float_array(take_string(natural_language_mac_embed_contextual(c_text, c_language)));
}

static VALUE rb_natural_language_mac_contextual_dimension(VALUE self, VALUE language) {
    VALUE dimension = take_string(natural_language_mac_contextual_dimension(StringValueCStr(language)));
    return rb_funcall(dimension, rb_intern("to_i"), 0);
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
