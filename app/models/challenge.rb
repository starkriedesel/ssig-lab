class Challenge < ActiveRecord::Base
  FLAG_TYPES = {none: 0, single: 1, random: 2, set: 3, any_set: 4, regex: 5, ruby_gen: 6, ruby_check: 7}
  DEFAULT_FLAG_TYPE = FLAG_TYPES[:random]

  #attr_accessible :name, :description, :challenge_group_id, :url, :points, :flag_type, :flag_data, :challenge_hints_attributes

  # Markdown support for Description
  extend MarkdownSupport
  with_markdown :description

  # Enums
  enum launch_type: [:launch_none, :launch_download, :launch_docker]
  enum submit_type: [:submit_simple, :submit_service, :submit_auto]

  # Validations
  validates :name, :presence => true
  validates :challenge_group_id, :presence => true
  validates :points, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :launch_type, presence: true
  validates :submit_type, presence: true
  validates :url, :presence => true, :format => {:with => /\Ahttps?:\/\/.+\z/}, if: :launch_download? # URL only required for download types
  validates :docker_image_name, presence: true, if: :launch_docker? # Docker image only required for docker types
  validates :submit_type, exclusion: {in: %w(submit_service)}, unless: :launch_docker? # Only docker has services
  validates :submit_type, inclusion: {in: %w(submit_simple)}, if: :launch_none? # Launch none must have simple submit

  serialize :flag_data, Hash

  # Callbacks
  after_initialize :default_values
  before_update :flag_data_check
  after_update :clear_flags_on_update
  
  # Associations
  belongs_to :challenge_group
  has_many :challenge_flags
  has_many :user_completed_challenges
  has_many :users_completed, :class_name => 'User', :through => :user_completed_challenges, :source => :user
  has_many :challenge_hints
  
  # Nested Form Associations
  accepts_nested_attributes_for :challenge_hints, allow_destroy: true, reject_if: proc {|attr| attr['cost'].to_i < 0 or attr['hint_text'].blank?}
  
  def opened_hints_for_user(user)
    user.challenge_hints.where(:id => self.challenge_hints.select('id'))
  end

  def flag_type_name
    Challenge::FLAG_TYPES.key self.flag_type
  end

  private
  def default_values # Sets the default values (both for Model.new and Model.find)
    # Ignore missing attribute errors
    begin
      self.flag_type ||= Challenge::DEFAULT_FLAG_TYPE
    rescue ActiveModel::MissingAttributeError
    end
    begin
      self.flag_data ||= {}
    rescue ActiveModel::MissingAttributeError
    end
  end

  def flag_data_check # Checks the flag_data for proper construction
    return unless self.flag_data?
    unless self.flag_data.kind_of? Hash
      self.flag_data = {}
    end

    # Set
    flag_data[:set] = [] if flag_data[:set].nil? or not flag_data[:set].kind_of? Array
    flag_data[:set].select! do |set_value|
      set_value = set_value.try(:to_s) || ''
      set_value.length > 0
    end


    # Any Set
    flag_data[:any_set] = [] if flag_data[:any_set].nil? or not flag_data[:any_set].kind_of? Array
    flag_data[:any_set].select! do |set_value|
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
    if flag_data.nil?
      flag_data[section] = ''
    elsif not flag_data[section].kind_of? String
      flag_data[section] = flag_data[section].try(:to_s) || ''
    end
  end

  def clear_flags_on_update
    if self.flag_type_changed? or self.flag_data_changed?
      ChallengeFlag.destroy_all(:challenge_id => self.id)
    end
  end
end
