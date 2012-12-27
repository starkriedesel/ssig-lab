require 'test_helper'

class ChallengesControllerTest < ActionController::TestCase
  def show_gets_challenge
    get 'show'
    assert_kind_of Challenge, assigns('challenge')
  end
end
