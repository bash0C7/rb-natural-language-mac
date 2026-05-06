# frozen_string_literal: true

require "test_helper"

class NaturalLanguageMacTest < Test::Unit::TestCase
  test "detect_language returns BCP-47 tag for English" do
    assert_equal("en", NaturalLanguageMac.detect_language("This is a clear English sentence for detection."))
  end

  test "detect_language returns BCP-47 tag for Japanese" do
    assert_equal("ja", NaturalLanguageMac.detect_language("これは日本語の文章です。判定してください。"))
  end

  test "detect_language returns empty string for empty input" do
    assert_equal("", NaturalLanguageMac.detect_language(""))
  end

  test "tokenize returns newline-separated tokens" do
    tokens = NaturalLanguageMac.tokenize("Hello world test.").split("\n")
    assert_equal(%w[Hello world test], tokens)
  end

  test "tokenize handles Japanese text" do
    tokens = NaturalLanguageMac.tokenize("これはテストです").split("\n")
    assert_false(tokens.empty?, "Expected at least one Japanese token")
    assert(tokens.any? { |t| t.include?("テスト") }, "Expected token containing 'テスト', got: #{tokens.inspect}")
  end

  test "tag returns token-tag pairs separated by tab and newline" do
    output = NaturalLanguageMac.tag("The quick fox jumps.")
    pairs = output.split("\n").map { |line| line.split("\t") }
    assert(pairs.all? { |p| p.length == 2 }, "Expected token\\ttag pairs, got: #{output.inspect}")
    tokens = pairs.map(&:first)
    assert_equal(%w[The quick fox jumps], tokens)
    tags = pairs.map(&:last)
    assert(tags.include?("Determiner"), "Expected 'Determiner' tag for 'The', got: #{tags.inspect}")
    assert(tags.include?("Verb"), "Expected 'Verb' tag for 'jumps', got: #{tags.inspect}")
  end

  test "tag returns empty string for empty input" do
    assert_equal("", NaturalLanguageMac.tag(""))
  end
end
