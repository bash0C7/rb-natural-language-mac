# frozen_string_literal: true

require "test_helper"

class EmbedSentenceTest < Test::Unit::TestCase
  SUPPORTED_LANG = "ja"

  test "embed_sentence returns Array<Float> for Japanese sentence" do
    result = NaturalLanguageMac.embed_sentence("こんにちは世界", SUPPORTED_LANG)
    omit "Apple NL sentence embedding unavailable for '#{SUPPORTED_LANG}' on this machine" if result.empty?
    assert_kind_of(Array, result)
    assert_operator(result.size, :>, 0)
    assert_kind_of(Float, result.first)
  end

  test "embed_sentence returns same dimension across calls" do
    a = NaturalLanguageMac.embed_sentence("最初の文章です", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_sentence("別の文章にしましょう", SUPPORTED_LANG)
    omit "Apple NL sentence embedding unavailable for '#{SUPPORTED_LANG}' on this machine" if a.empty? || b.empty?
    assert_equal(a.size, b.size)
  end

  test "embed_sentence returns different vectors for different sentences" do
    a = NaturalLanguageMac.embed_sentence("天気が良い日です", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_sentence("プログラミングは楽しい", SUPPORTED_LANG)
    omit "Apple NL sentence embedding unavailable for '#{SUPPORTED_LANG}' on this machine" if a.empty? || b.empty?
    refute_equal(a, b, "Expected different sentences to produce different vectors")
  end

  test "embed_sentence returns empty array for empty text" do
    assert_equal([], NaturalLanguageMac.embed_sentence("", SUPPORTED_LANG))
  end

  test "embed_sentence returns empty array for empty language" do
    assert_equal([], NaturalLanguageMac.embed_sentence("hello", ""))
  end

  test "embed_sentence returns empty array for unsupported language" do
    assert_equal([], NaturalLanguageMac.embed_sentence("hello", "xx-not-a-language"))
  end

  test "embedding_dimension returns positive Integer for Japanese" do
    dim = NaturalLanguageMac.embedding_dimension(SUPPORTED_LANG)
    omit "Apple NL sentence embedding unavailable for '#{SUPPORTED_LANG}' on this machine" if dim.zero?
    assert_kind_of(Integer, dim)
    assert_operator(dim, :>, 0)
  end

  test "embedding_dimension returns 0 for empty language" do
    assert_equal(0, NaturalLanguageMac.embedding_dimension(""))
  end

  test "embedding_dimension returns 0 for unsupported language" do
    assert_equal(0, NaturalLanguageMac.embedding_dimension("xx-not-a-language"))
  end

  test "embed_sentence size matches embedding_dimension" do
    dim = NaturalLanguageMac.embedding_dimension(SUPPORTED_LANG)
    omit "Apple NL sentence embedding unavailable for '#{SUPPORTED_LANG}' on this machine" if dim.zero?
    vec = NaturalLanguageMac.embed_sentence("テスト用の文章", SUPPORTED_LANG)
    omit "Apple NL sentence embedding returned empty vector" if vec.empty?
    assert_equal(dim, vec.size)
  end
end
