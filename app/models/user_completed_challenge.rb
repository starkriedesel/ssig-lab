class UserCompletedChallenge < ActiveRecord::Base
  self.primary_keys= :user_id, :challenge_id
  
  belongs_to :user
  belongs_to :challenge
end
