class ChallengeGroup < ActiveRecord::Base
  attr_accessible :name, :description
  
  validates :name, :presence => true, :uniqueness => true
  
  has_many :challenges
end
