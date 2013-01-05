class ChallengeFlag < ActiveRecord::Base
  require "digest"
  
  self.primary_keys= :user_id, :challenge_id
  
  belongs_to :user
  belongs_to :challenge
  
  def self.generate_flag_string
    [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten.shuffle[0,16].join
  end
  
  def self.generate_nonce
    Digest::MD5.hexdigest(Time.now.to_s).to_s
  end
  
  def self.generate_flag!(user_id, challenge)
    flag_type = challenge.flag_type_name
    flag_str = nil
    if [:random, :single, :set, :ruby_gen].include? flag_type
      eval "flag_str = self.generate_flag_#{flag_type}(challenge)"
    end
    if flag_str.nil?
      raise "ChallengeFlag cannot be generated"
    end
    flag = ChallengeFlag.where(:user_id => user_id, :challenge_id => challenge.id).first
    flag ||= ChallengeFlag.create({user_id: user_id, challenge_id: challenge.id, value: flag_str, nonce: generate_nonce})
    flag
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
      logger.debug "flag_str = #{flag_str}"
    rescue
      flag_str = nil
    end
    flag_str = nil unless flag_str.kind_of? String and flag_str.length > 0
    flag_str
  end
end
