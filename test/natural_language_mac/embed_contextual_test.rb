# frozen_string_literal: true

require "test_helper"

class EmbedContextualTest < Test::Unit::TestCase
  SUPPORTED_LANG = "ja"

  test "embed_contextual returns Array<Float> for Japanese sentence" do
    result = NaturalLanguageMac.embed_contextual("これは日本語の文章です", SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if result.empty?
    assert_kind_of(Array, result)
    assert_operator(result.size, :>, 0)
    assert_kind_of(Float, result.first)
  end

  test "embed_contextual returns same dimension across calls" do
    a = NaturalLanguageMac.embed_contextual("最初の文章です", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_contextual("別の文章にしましょう", SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if a.empty? || b.empty?
    assert_equal(a.size, b.size)
  end

  test "embed_contextual returns different vectors for different sentences" do
    a = NaturalLanguageMac.embed_contextual("天気が良い日です", SUPPORTED_LANG)
    b = NaturalLanguageMac.embed_contextual("プログラミングは楽しい", SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if a.empty? || b.empty?
    refute_equal(a, b, "Expected different sentences to produce different vectors")
  end

  test "embed_contextual returns empty array for empty text" do
    assert_equal([], NaturalLanguageMac.embed_contextual("", SUPPORTED_LANG))
  end

  test "embed_contextual returns empty array for empty language" do
    assert_equal([], NaturalLanguageMac.embed_contextual("hello", ""))
  end

  test "embed_contextual returns empty array for unsupported language" do
    assert_equal([], NaturalLanguageMac.embed_contextual("hello", "xx-not-a-language"))
  end

  test "contextual_dimension returns positive Integer for Japanese" do
    dim = NaturalLanguageMac.contextual_dimension(SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if dim.zero?
    assert_kind_of(Integer, dim)
    assert_operator(dim, :>, 0)
  end

  test "contextual_dimension returns 0 for empty language" do
    assert_equal(0, NaturalLanguageMac.contextual_dimension(""))
  end

  test "contextual_dimension returns 0 for unsupported language" do
    assert_equal(0, NaturalLanguageMac.contextual_dimension("xx-not-a-language"))
  end

  test "embed_contextual size matches contextual_dimension" do
    dim = NaturalLanguageMac.contextual_dimension(SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if dim.zero?
    vec = NaturalLanguageMac.embed_contextual("テスト用の文章です", SUPPORTED_LANG)
    omit "NLContextualEmbedding returned empty vector" if vec.empty?
    assert_equal(dim, vec.size)
  end

  test "embed_contextual semantically similar sentences are closer than unrelated" do
    near_a = NaturalLanguageMac.embed_contextual("今日はとても良い天気です", SUPPORTED_LANG)
    near_b = NaturalLanguageMac.embed_contextual("本日は晴天で気持ちが良い", SUPPORTED_LANG)
    far    = NaturalLanguageMac.embed_contextual("プログラミング言語の選択", SUPPORTED_LANG)
    omit "NLContextualEmbedding unavailable for '#{SUPPORTED_LANG}' on this machine" if near_a.empty? || near_b.empty? || far.empty?

    cos = ->(a, b) {
      dot = a.zip(b).sum { |x, y| x * y }
      na = Math.sqrt(a.sum { |x| x * x })
      nb = Math.sqrt(b.sum { |x| x * x })
      dot / (na * nb)
    }
    sim_near = cos.call(near_a, near_b)
    sim_far  = cos.call(near_a, far)
    assert_operator(sim_near, :>, sim_far, "weather sentences should be closer than weather vs programming (near=#{sim_near.round(3)} far=#{sim_far.round(3)})")
  end
end
