class ChallengesController < ApplicationController
  # Controler authorized actions by Cancan
  load_and_authorize_resource
  
  # Skip the CSRF protection for Challenges#Complete because data is being posted by apache server
  skip_before_filter :verify_authenticity_token, :only=>:complete
  
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
    logger.debug "Update before: #{params[:challenge]}"
    if @challenge.update_attributes(params[:challenge])
      logger.debug "Update after: #{@challenge.challenge_hints[0].hint_text_use_markdown}"
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
    if @flag.value == params[:flag]
      @flag.destroy
      if current_user.completed_challenges.include? @challenge
        flash[:notice] = "That was correct, but you have already completed '#{@challenge.name}'"
      else
        current_user.completed_challenges << @challenge;
        current_user.points += @challenge.points - (@challenge.opened_hints_for_user(current_user).sum(:cost))
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
  
  def show_hint
    if user_signed_in?
      if not current_user.completed_challenges.include? @challenge
        hints_for_user = @challenge.opened_hints_for_user current_user
        num_hints = @challenge.challenge_hints.count
        if hints_for_user.count < num_hints
          new_hint = @challenge.challenge_hints[hints_for_user.count]
          if new_hint.id.to_s == params[:challenge_hint_id]
            current_user.challenge_hints << new_hint
            flash[:info] = "Hint for challenge '#{@challenge.name} shown. You will recieve #{new_hint.cost} fewer points for completing this challenge."
          end
        end
      else
        flash[:error] = "Cannot show hint for challenge already completed"
      end
    end
    redirect_to @challenge
  end
end

