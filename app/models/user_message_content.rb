class UserMessageContent < ActiveRecord::Base
  attr_accessible :content, :from_name, :subject, :user_messages_attributes

  validates :content, :presence => true
  validates :subject, :presence => true
  validates :user_id, :presence => true

  belongs_to :user
  has_many :user_messages, :dependent => :destroy

  accepts_nested_attributes_for :user_messages
end
