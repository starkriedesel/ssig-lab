class ChallengesController < ApplicationController
  load_and_authorize_resource
  skip_before_filter :verify_authenticity_token, :only=>:complete
  
  # GET /challenges
  def index
  end

  # GET /challenges/:id
  def show
    @flag = Flag.generate_flag!(current_user.id, @challenge.id)
  end
  
  # GET /challenges/new
  def new
    if not params[:group_id].blank?
      @challenge.challenge_group = ChallengeGroup.find(params[:group_id])
    end
  end
  
  # GET /challenges/:id/edit
  def edit
  end
  
  # POST /Challenges
  def create
    @challenge = Challenge.new(params[:challenge])
    if @challenge.save
      flash[:notice] = "Created Challenge '#{@challenge.name}'" 
      redirect_to @challenge
    else
      render :action => 'new'
    end
  end
  
  # PUT /challenges/:id
  def update
    if @challenge.update_attributes(params[:challenge])
      flash[:notice] = "Challenge '#{@challenge.name}' was successfully updated"
      if @challenge.challenge_group.nil?
        redirect_to challenge_groups_path
      else
        redirect_to @challenge.challenge_group
      end
    else
      render :action => 'edit'
    end
  end
  
  # DELETE /challenges/:id
  def destroy
    challenge_group = @challenge.challenge_group
    @challenge.destroy
    if challenge_group.nil?
      redirect_to challenge_groups_path
    else
      redirect_to challenge_group
    end
  end
  
  # POST /challenges/:id/complete
  def complete
    @challenge = Challenge.find(params[:id])
    @flag = Flag.find([current_user.id, @challenge.id])
    
    # Correct flag
    if @flag.value == params[:flag]
      @flag.destroy
      if not current_user.completed_challenges.find(@challenge.id).nil?
        flash[:notice] = "That was correct, but you have already completed '#{@challenge.name}'"
      else
        current_user.completed_challenges << @challenge;
        if current_user.save
          flash[:success] = "You completed '#{@challenge.name}' and recieved #{@challenge.points} points!";
        else
          flash[:error] = "There was a problem updating your completed challenges for '#{@challenge.name}'";
        end
      end
      redirect_to @challenge.challenge_group
      return
    # Incorrect flag
    else
      flash[:error] = "Incorrect flag value for '#{@challenge.name}'. Try again."
      redirect_to @challenge.challenge_group
      return
    end
  end
end

