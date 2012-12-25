class ChallengeFlag < ActiveRecord::Base
  require "digest"
  
  self.primary_keys= :user_id, :challenge_id
  
  belongs_to :user
  belongs_to :challenge
  
  def self.generate_flag
    [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten.shuffle[0,16].join
  end
  
  def self.generate_nonce
    Digest::MD5.hexdigest(Time.now.to_s).to_s
  end
  
  def self.generate_flag!(user_id, challenge_id)
    flag = ChallengeFlag.where(:user_id => user_id, :challenge_id => challenge_id).first
    flag ||= ChallengeFlag.create({user_id: user_id, challenge_id: challenge_id, value: generate_flag, nonce: generate_nonce})
    flag
  end
end
