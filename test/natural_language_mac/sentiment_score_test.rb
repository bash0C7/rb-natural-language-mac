# frozen_string_literal: true

require "test_helper"

class SentimentScoreTest < Test::Unit::TestCase
  test "sentiment_score returns positive Float for clearly positive English" do
    score = NaturalLanguageMac.sentiment_score("I love this. It is wonderful, amazing and absolutely fantastic!")
    omit "sentimentScore unavailable on this machine" if score.nil?
    assert_kind_of(Float, score)
    assert_operator(score, :>, 0.0, "positive text should score above 0")
  end

  test "sentiment_score returns negative Float for clearly negative English" do
    score = NaturalLanguageMac.sentiment_score("This is terrible. I hate it, it is awful and a complete disaster.")
    omit "sentimentScore unavailable on this machine" if score.nil?
    assert_kind_of(Float, score)
    assert_operator(score, :<, 0.0, "negative text should score below 0")
  end

  test "sentiment_score returns a Float (not nil) for neutral text" do
    score = NaturalLanguageMac.sentiment_score("The meeting is scheduled for three o'clock on Tuesday.")
    omit "sentimentScore unavailable on this machine" if score.nil?
    assert_kind_of(Float, score)
  end

  test "sentiment_score returns a Float in range -1.0..1.0" do
    score = NaturalLanguageMac.sentiment_score("I love this. It is wonderful, amazing and absolutely fantastic!")
    omit "sentimentScore unavailable on this machine" if score.nil?
    assert_operator(score, :>=, -1.0)
    assert_operator(score, :<=, 1.0)
  end

  test "sentiment_score returns a Float for Japanese text (sign unverified)" do
    score = NaturalLanguageMac.sentiment_score("これはとても素晴らしい一日でした。本当に楽しかったです。")
    omit "sentimentScore unavailable for Japanese on this machine" if score.nil?
    assert_kind_of(Float, score)
  end

  test "sentiment_score returns nil for empty input" do
    assert_nil(NaturalLanguageMac.sentiment_score(""))
  end
end
