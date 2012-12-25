class Challenge < ActiveRecord::Base
  attr_accessible :name, :description, :challenge_group_id, :url, :points, :hint
  
  validates :name, :presence => true
  validates :challenge_group_id, :presence => true
  validates :url, :presence => true, :format => {:with => /^https?:\/\/.+$/}
  validates :points, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  
  belongs_to :challenge_group
  
  has_many :challenge_flags
  
  has_many :user_completed_challenges
  has_many :users_completed, :class_name => "User", :through => :user_completed_challenges, :source => :user
end
