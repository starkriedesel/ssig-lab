class LeaderboardsController < ApplicationController
	def index
	  # Initialize data
	  @filter_list = []
	  @leaderboard_name = nil
	  @leaderboard_name_link = nil
	  @leaderboard = User.joins(:user_completed_challenges, :user_completed_challenges => :challenge)
	                     .select('users.*, MAX(user_completed_challenges.created_at) as last_completed_at, COUNT(user_completed_challenges.challenge_id) as num_challenges_completed, SUM(challenges.points) as subset_points')
                       .group('users.id')
                       .order('subset_points DESC, last_completed_at ASC')
	  
	  # Create filters
	  filter_by_challenge_id params[:challenge_id] unless params[:challenge_id].nil?
	  filter_by_challenge_group_id params[:challenge_group_id] unless params[:challenge_group_id].nil?
	  
	  # Fina all users that meet criteria
	  @leaderboard = @leaderboard.all
	end
	
	private
	def filter_by_challenge_id(challenge_id)
	  @challenge = Challenge.find(challenge_id)
	  @leaderboard = @leaderboard.where(:user_completed_challenges => {:challenge_id => challenge_id})
	  @leaderboard_name = @challenge.name
	  @leaderboard_name_link = @challenge
	  @filter_list << 'challenge'
	end
	
	def filter_by_challenge_group_id(challenge_group_id)
	  @challenge_group = ChallengeGroup.find(challenge_group_id)
	  @leaderboard = @leaderboard.where(:user_completed_challenges => {:challenge_id => @challenge_group.challenges.select{|c| c.id}})
	  @leaderboard_name = "#{@challenge_group.name} Group"
	  @leaderboard_name_link = @challenge_group
	  @filter_list << 'challenge_group'
	end
end