class ChallengeGroupsController < ApplicationController
  load_and_authorize_resource
  
  # GET /challengeGroups
	def index
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
    @challenge_group = ChallengeGroup.new(params[:challenge_group])
    if @challenge_group.save
      flash[:notice] = "Created Challenge Group '#{@challenge_group.name}'" 
      redirect_to @challenge_group
    else
      render :action => 'new'
    end
  end
  
  # PUT /ChallengeGroups/:id
  def update
    if @challenge_group.update_attributes(params[:challenge_group])
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
end