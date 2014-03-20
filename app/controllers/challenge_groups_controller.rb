class ChallengeGroupsController < ApplicationController
  load_and_authorize_resource
   skip_load_resource only: [:create]
  
  # GET /challengeGroups
	def index
	  @num_complete = {}
	  @subset_points = {}
	  if user_signed_in?
	    @num_complete = current_user.completed_challenges.group(:challenge_group_id).count
      @subset_points = current_user.completed_challenges.group(:challenge_group_id).sum(:points)
      @subset_costs = current_user.challenge_hints.joins(:challenge).where(challenge_id: current_user.completed_challenges.map(&:id)).group(:challenge_group_id).sum(:cost)
	  end
	  @group_totals = Challenge.group(:challenge_group_id).sum(:points)
	end
	
	# GET /challengeGroups/:id
	def show
  end
  
  # GET /challengeGroups/new
  def new
  end
  
  # GET /challengeGroups/:id/edit
  def edit
  end
  
  # POST /ChallengeGroups
  def create
    @challenge_group = ChallengeGroup.new(challenge_group_params)
    if @challenge_group.save
      flash[:notice] = "Created Challenge Group '#{@challenge_group.name}'" 
      redirect_to @challenge_group
    else
      render :action => 'new'
    end
  end
  
  # PUT /ChallengeGroups/:id
  def update
    if @challenge_group.update_attributes(challenge_group_params)
      flash[:notice] = "Challenge Group '#{@challenge_group.name}' was successfully updated"
      redirect_to @challenge_group
    else
      render :action => 'edit'
    end
  end
  
  # DELETE /ChallengeGroups/:id
  def destroy
    if @challenge_group.challenges.any?
      flash[:error] = "Cannot remove challenge group '#{@challenge_group.name}' as it is not empty."
      redirect_to challenge_groups_path
    end
    @challenge_group.destroy
    redirect_to challenge_groups_path
  end

  private
  def challenge_group_params
    params.require(:challenge_group).permit(:name, :description)
  end
end
