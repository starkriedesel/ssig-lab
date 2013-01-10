class UserMessage < ActiveRecord::Base
  attr_accessible :read, :user_id, :user_message_content_id

  validates :user_id, :presence => true
  #validates :user_message_content_id, :presence => true

  belongs_to :user
  belongs_to :user_message_content

  after_initialize :normalize_read
  after_find :normalize_read
  
  private
  def normalize_read
    if self.read? and self.read.nil?
      self.read = false
    end
  end
end
