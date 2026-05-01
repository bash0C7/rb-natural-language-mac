#ifndef NATURAL_LANGUAGE_MAC_H
#define NATURAL_LANGUAGE_MAC_H

char *natural_language_mac_detect_language(const char *text);
char *natural_language_mac_tokenize(const char *text);
char *natural_language_mac_tag(const char *text);
void natural_language_mac_free(char *ptr);

#endif
