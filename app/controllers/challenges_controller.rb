class ChallengesController < ApplicationController
  # Controler authorized actions by Cancan
  load_and_authorize_resource
  skip_load_resource only: [:create]

  # Skip the CSRF protection for Challenges#Complete because data is being posted by apache server
  skip_before_filter :verify_authenticity_token, only: :complete
  
  # GET /challenges
  def index
  end

  # GET /challenges/:id
  def show
    unless current_user.nil?
      @current_user_flag = ChallengeFlag.find_by(user_id: current_user.id, challenge_id: @challenge.id)
      if @current_user_flag && @challenge.launch_docker?
        if @current_user_flag.nil?
          @docker_status = nil
        else
          @docker_status = DockerLauncher.get_instance(@current_user_flag.docker_host_name).status_challenge(@challenge, @current_user_flag, current_user)
        end
      else
        @docker_status = nil
      end
    end
  end

  # GET /challenges/:id/launch
  def launch
    if current_user.launched_challenges.count > 0
      flash[:error] = ('Only one challenge may be in progress at a time. ' +
          'Please give up on any currently active challenges. ' +
          "Your active challenges are: #{current_user.launched_challenges.map{|c| view_context.link_to(c.name,c)}.join(', ')}").html_safe
      redirect_to @challenge
      return
      # NOTE: If we don't limit to one challenge then we should make sure that the user doesn't launch the same one twice
    end

    @flag = ChallengeFlag.generate_flag(current_user.id, @challenge)
    if @challenge.launch_docker?
      launcher = DockerLauncher.get_instance
      raise 'Cannot allocate docker instance for this challenge' if launcher.nil?
      @flag.docker_container_id = launcher.launch_challenge(@challenge, @flag, current_user)
      @flag.docker_host_name = launcher.host_name
    end

    flash[:error] = 'Could not launch instance of challenge.' unless @flag.save
    redirect_to @challenge
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
    params = challenge_params
    if @challenge.update_attributes(params)
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
    if @challenge.submit_simple?
      @flag = ChallengeFlag.find([current_user.id, @challenge.id])

      # Correct flag
      if @flag.check params[:flag]
        @flag.destroy
        if @challenge.launch_docker?
          DockerLauncher.get_instance(@flag.docker_host_name).kill_challenge(@challenge, @flag, @flag.user)
        end
        if current_user.completed_challenges.include? @challenge
          flash[:notice] = "That was correct, but you have already completed '#{@challenge.name}'"
        else
          current_user.completed_challenges << @challenge
          current_user.points += @challenge.points - (@challenge.opened_hints_for_user(current_user).sum(:cost))
          if current_user.save
            flash[:success] = "You completed '#{@challenge.name}' and received #{@challenge.points} points!"
          else
            flash[:error] = "There was a problem updating your completed challenges for '#{@challenge.name}'"
          end
        end
        redirect_to @challenge

      # Incorrect flag
      else
        flash[:error] = "Incorrect flag value for '#{@challenge.name}'. Try again."
        redirect_to @challenge
      end
    else
      raise "Submit type '#{@challenge.submit_type.split('_',2)[1].humanize}' has not been implemented"
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

  def tag_search
    @tag = params[:tag]
    @challenges = Challenge.tagged_with(@tag)
  end

  private
  def challenge_params
    params.require(:challenge).permit(:challenge_group_id, :name, :tag_list, :url, :points, :flag_type, :description,
                                      :description_use_markdown, :launch_type, :submit_type, :docker_image_name,
                                      challenge_hints_attributes: [:id, :hint_text, :cost, :hint_text_use_markdown, :_destroy],
                                      flag_data: [Challenge::FLAG_TYPES.keys, set: []])
  end
end

