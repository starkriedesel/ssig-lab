class ChallengesController < ApplicationController
  # Controler authorized actions by Cancan
  load_and_authorize_resource
  
  # Skip the CSRF protection for Challenges#Complete because data is being posted by apache server
  skip_before_filter :verify_authenticity_token, only: :complete
  
  # GET /challenges
  def index
  end

  def show
  end

  # GET /challenges/:id/goto
  def goto
    @flag = ChallengeFlag.generate_flag!(current_user.id, @challenge)
  end
  
  # GET /challenges/new
  def new
    @challenge.challenge_group = ChallengeGroup.find(params[:group_id]) unless params[:group_id].blank?
  end
  
  # GET /challenges/:id/edit
  def edit
  end
  
  # POST /Challenges
  def create
    @challenge = Challenge.new(challenge_params)
    if @challenge.save
      flash[:notice] = "Created Challenge '#{@challenge.name}'" 
      redirect_to @challenge
    else
      render :action => 'new'
    end
  end
  
  # PUT /challenges/:id
  def update
    if @challenge.update_attributes(challenge_params)
      @challenge.users_completed.each{|u| u.update_points} # update points for all users who completed this challenge
      flash[:notice] = "Challenge '#{@challenge.name}' was successfully updated"
      redirect_to @challenge
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
    @flag = ChallengeFlag.find([current_user.id, @challenge.id])
    
    # Correct flag
    if @flag.check params[:flag]
      @flag.destroy
      if current_user.completed_challenges.include? @challenge
        flash[:notice] = "That was correct, but you have already completed '#{@challenge.name}'"
      else
        current_user.completed_challenges << @challenge
        current_user.points += @challenge.points - (@challenge.opened_hints_for_user(current_user).sum(:cost))
        if current_user.save
          flash[:success] = "You completed '#{@challenge.name}' and recieved #{@challenge.points} points!"
        else
          flash[:error] = "There was a problem updating your completed challenges for '#{@challenge.name}'"
        end
      end
      redirect_to @challenge.challenge_group

    # Incorrect flag
    else
      flash[:error] = "Incorrect flag value for '#{@challenge.name}'. Try again."
      redirect_to @challenge.challenge_group
    end
  end
  
  def show_hint
    if user_signed_in?
      if current_user.completed_challenges.include? @challenge
        flash[:error] = 'Cannot show hint for challenge already completed'
      else
        hints_for_user = @challenge.opened_hints_for_user current_user
        num_hints = @challenge.challenge_hints.count
        if hints_for_user.count < num_hints
          new_hint = @challenge.challenge_hints[hints_for_user.count]
          if new_hint.id.to_s == params[:challenge_hint_id]
            current_user.challenge_hints << new_hint
            flash[:info] = "Hint for challenge '#{@challenge.name} shown. You will receive #{new_hint.cost} fewer points for completing this challenge."
          end
        end
      end
    end
    redirect_to @challenge
  end

  private
  def challenge_params
    params.require(:challenge).permit(:challenge_group_id, :name, :url, :points, :flag_type, :flag_data, :description, :description_use_markdown,
                                      challenge_hints_attributes: [:id, :hint_text, :cost, :_destroy],
                                      flag_data: [Challenge::FLAG_TYPES.keys, set: []])
  end
end

