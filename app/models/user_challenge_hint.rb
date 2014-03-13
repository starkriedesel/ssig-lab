class UserChallengeHint < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge_hint
end