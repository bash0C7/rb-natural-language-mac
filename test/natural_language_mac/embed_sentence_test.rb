# frozen_string_literal: true

require "test_helper"

class EmbedSentenceTest < Test::Unit::TestCase
  SUPPORTED_LANG = "en"

  test "embed_sentence returns Array<Float> for an English sentence" do
    result = NaturalLanguageMac.embed_sentence("Hello world.", SUPPORTED_LANG)
    assert_operator(result.size, :>, 0)
    assert(result.all?(Float), "Expected Float elements, got: #{result.first(3).inspect}")
  end

  test "embed_sentence returns same dimension across calls" do
    a = NaturalLanguageMac.embed_sentence("This is the first sentence.", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_sentence("Let us write another one.", SUPPORTED_LANG)
    assert_equal(a.size, b.size)
  end

  test "embed_sentence returns different vectors for different sentences" do
    a = NaturalLanguageMac.embed_sentence("It is a fine day.", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_sentence("Programming is fun.", SUPPORTED_LANG)
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

  test "embed_sentence returns empty array for Japanese, which ships no sentence embedding" do
    assert_equal([], NaturalLanguageMac.embed_sentence("こんにちは世界", "ja"))
  end

  test "embedding_dimension returns positive Integer for English" do
    dim = NaturalLanguageMac.embedding_dimension(SUPPORTED_LANG)
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
    vec = NaturalLanguageMac.embed_sentence("A sentence for testing.", SUPPORTED_LANG)
    assert_equal(dim, vec.size)
  end
end
