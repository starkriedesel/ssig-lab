class Challenge < ActiveRecord::Base
  include ApplicationHelper

  attr_accessor :use_markdown
  attr_accessible :name, :description, :challenge_group_id, :url, :points, :hint, :use_markdown
  
  validates :name, :presence => true
  validates :challenge_group_id, :presence => true
  validates :url, :presence => true, :format => {:with => /^https?:\/\/.+$/}
  validates :points, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  
  belongs_to :challenge_group
  
  has_many :challenge_flags
  
  has_many :user_completed_challenges
  has_many :users_completed, :class_name => "User", :through => :user_completed_challenges, :source => :user

  def description_html
    show_with_markdown self.description, self.use_markdown
  end

  before_save :description_markdown_save
  def description_markdown_save
    self.use_markdown = self.use_markdown == '1'
    self.description = save_with_markdown self.description, self.use_markdown
  end

  after_find :description_markdown_find
  def description_markdown_find
    self.use_markdown = check_with_markdown self.description
    self.description = load_with_markdown self.description, self.use_markdown
  end

  after_initialize :description_markdown_init
  def description_markdown_init
    #self.use_markdown = false
  end
end
