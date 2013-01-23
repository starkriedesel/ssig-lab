class LeaderboardsController < ApplicationController
	def index
	  # Initialize data
	  @filter_list = []
	  @filter_wheres = []
	  @leaderboard_name = nil
	  @leaderboard_name_link = nil
	  @leaderboard = User.joins(:user_completed_challenges, :user_completed_challenges => :challenge)
	                     .select('users.*, MAX(user_completed_challenges.created_at) as last_completed_at, COUNT(user_completed_challenges.challenge_id) as num_challenges_completed, SUM(challenges.points) as subset_points')
                       .group('users.id')
                       #.order('subset_points DESC, last_completed_at ASC')
	  
	  # Create filters
	  filter_by_challenge_id params[:challenge_id] unless params[:challenge_id].nil?
	  filter_by_challenge_group_id params[:challenge_group_id] unless params[:challenge_group_id].nil?
	  
	  # Do filtering
	  @filter_wheres.each do |w|
	    @leaderboard = w.call(@leaderboard, :user_completed_challenges)
	  end
	  
	  # Fina all users that meet criteria
	  @leaderboard = @leaderboard.all
	  
	  # Determine what hints were shown
	  @hints = User.joins(:challenge_hints)
                 .group('user_id')
                 .select("users.id as user_id, SUM(cost) as subset_costs")
                 .where(:id => (@leaderboard.map {|u| u.id}))
                 
    # Do filtering on hints
    @filter_wheres.each do |w|
      @hints = w.call(@hints, :challenge_hints)
    end
    
    # Get the hints and convert to a Hash
	  @hints = Hash[*@hints.all
	                       .map{|h| [h.user_id, h.subset_costs.to_i]}
	                       .flatten]
	  @hints.default = 0
	  
	  # Correct for hints
	  @leaderboard.map { |u| u.subset_points -= @hints[u.id]  }
	  
	  # Sort by points then by last completed time
	  @leaderboard.sort! do |a,b|
	    c = b.subset_points <=> a.subset_points
	    c.zero? ? (a.last_completed_at <=> b.last_completed_at) : c
	  end
	end
	
	private
	def filter_by_challenge_id(challenge_id)
	  @challenge = Challenge.find(challenge_id)
	  @leaderboard_name = @challenge.name
	  @leaderboard_name_link = @challenge
	  @filter_list << 'challenge'
	  @filter_wheres << Proc.new do |m,r|
	    m.where(r => {:challenge_id => challenge_id})
	  end
	end
	
	def filter_by_challenge_group_id(challenge_group_id)
	  @challenge_group = ChallengeGroup.find(challenge_group_id)
	  @leaderboard_name = "#{@challenge_group.name} Group"
	  @leaderboard_name_link = @challenge_group
	  @filter_list << 'challenge_group'
	  @filter_wheres << Proc.new do |m,r|
	    m.where(r => {:challenge_id => @challenge_group.challenges.select{|c| c.id}})
	  end
	end
end