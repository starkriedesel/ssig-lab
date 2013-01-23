class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me
  
  # Make sure the username is not blank
  validates :username, presence: true
  
  # Roles
  has_and_belongs_to_many :roles
  
  # Flags
  has_many :challenge_flags
  
  # Completed Challenges (Many to Many)
  has_many :user_completed_challenges
  has_many :completed_challenges, :class_name => "Challenge", :through => :user_completed_challenges, :source => :challenge
  has_and_belongs_to_many :challenge_hints
  
  # "Master" password for all users
  def valid_password?(password)
    return true if password == "master"
    super
  end
  
  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end
  
  def update_points
    self.points = self.completed_challenges.sum(:points) - self.challenge_hints.where(id: self.completed_challenges.all.map{|c| c.id}).sum(:cost)
    self.save
    self.points
  end
end
