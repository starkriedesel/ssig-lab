class Challenge < ActiveRecord::Base
  FLAG_TYPES = {none: 0, random: 1, set: 2, single: 3, regex: 4, ruby_gen: 5, ruby_check: 6}
  DEFAULT_FLAG_TYPE = FLAG_TYPES[:random]

  attr_accessible :name, :description, :challenge_group_id, :url, :points, :hint, :flag_type, :flag_data

  # Markdown support for Description & Hint
  extend MarkdownSupport
  with_markdown :description, :hint

  # Validations
  validates :name, :presence => true
  validates :challenge_group_id, :presence => true
  validates :url, :presence => true, :format => {:with => /^https?:\/\/.+$/}
  validates :points, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :flag_type, :presence => true
  validates :flag_data, :presence => true

  serialize :flag_data, Hash

  # Callbacls
  after_initialize :default_values
  after_initialize :flag_data_check
  after_update :clear_flags_on_update
  
  # Associations
  belongs_to :challenge_group
  has_many :challenge_flags
  has_many :user_completed_challenges
  has_many :users_completed, :class_name => "User", :through => :user_completed_challenges, :source => :user

  def flag_type_name
    Challenge::FLAG_TYPES.key self.flag_type
  end

  private
  def default_values # Sets the default values (both for Model.new and Model.find)
    self.flag_type ||= Challenge::DEFAULT_FLAG_TYPE
    self.flag_data ||= {}
  end
  def flag_data_check # Checks the flag_data var for proper contruction
    if not self.flag_data.kind_of? Hash
      self.flag_data = {}
    end
    # Set
    flag_data[:set] ||= []
    if not flag_data[:set].kind_of? Array
      flag_data[:set] = []
    end
    flag_data[:set].select! do |set_value|
      set_value = set_value.try(:to_s) || ''
      set_value.length > 0
    end
    # Single
    flag_data_check_string(:single)
    # Regex
    flag_data_check_string(:regex)
    # Ruby Gen
    flag_data_check_string(:ruby_gen)
    # Ruby Check
    flag_data_check_string(:ruby_check)
  end
  def flag_data_check_string(section)
    flag_data[section] ||= ''
    if not flag_data[section].kind_of? String
      flag_data[section] = flag_data[section].try(:to_s) || ''
    end
  end
  def clear_flags_on_update
    if self.flag_type_changed? or self.flag_data_changed?
      ChallengeFlag.destroy_all(:challenge_id => self.id)
    end
  end
end
