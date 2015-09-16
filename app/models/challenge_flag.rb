class ChallengeFlag < ActiveRecord::Base
  require 'securerandom'
  
  self.primary_keys= :user_id, :challenge_id

  validates :user_id, presence: true
  validates :challenge_id, presence: true
  validates :docker_container_id, uniqueness: true, presence: true, if: :is_docker_flag # require a container id for docker challenges
  validates :docker_host_name, presence: true, if: :is_docker_flag # require a host name for docker challenges
  
  belongs_to :user
  belongs_to :challenge
  
  def self.generate_flag_string
    [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten.shuffle[0,16].join
  end
  
  def self.generate_nonce
    SecureRandom.hex
  end
  
  def self.generate_flag(user_id, challenge)
    flag_type = challenge.flag_type_name
    flag_str = nil
    if [:random, :single, :set, :ruby_gen].include? flag_type
      eval "flag_str = self.generate_flag_#{flag_type}(challenge)"
    elsif flag_type == :any_set
      flag_str = "[#{challenge.flag_data[:set].join(',')}]" 
    elsif flag_type == :ruby_check
      flag_str = flag_type.to_s
    end
    raise 'ChallengeFlag cannot be generated' if flag_str.nil?
    flag = ChallengeFlag.where(user_id: user_id, :challenge_id => challenge.id).first
    flag ||= ChallengeFlag.create({user_id: user_id, challenge_id: challenge.id, value: flag_str, nonce: generate_nonce})
    flag.nonce ||= generate_nonce
    flag
  end

  def check(attempt)
    if challenge.flag_type == Challenge::FLAG_TYPES[:any_set]
      return challenge.flag_data[:set].include? attempt
    elsif challenge.flag_type == Challenge::FLAG_TYPES[:ruby_check]
      check_code = challenge.flag_data[:ruby_check]
      return !! lambda {|flag_value| eval check_code }.call(attempt)
    end
    value == attempt
  end

  def is_docker_flag
    challenge.launch_docker?
  end

  private
  def self.generate_flag_random(challenge)
    self.generate_flag_string
  end

  def self.generate_flag_single(challenge)
    single_value = challenge.flag_data[:single]
    return nil unless single_value.kind_of? String and single_value.length > 0
    return single_value
  end

  def self.generate_flag_set(challenge)
    set_values = challenge.flag_data[:set]
    return nil unless set_values.kind_of? Array and set_values.length > 0
    return set_values.sample
  end

  def self.generate_flag_ruby_gen(challenge)
    gen_code = challenge.flag_data[:ruby_gen]
    flag_str = nil
    return nil unless gen_code.kind_of? String
    begin
      flag_str = lambda { eval gen_code }.call.to_s
    rescue
      flag_str = nil
    end
    flag_str = nil unless flag_str.kind_of? String and flag_str.length > 0
    flag_str
  end
end
