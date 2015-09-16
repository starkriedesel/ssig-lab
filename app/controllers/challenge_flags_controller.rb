class ChallengeFlagsController < ApplicationController
  load_and_authorize_resource

  # DELETE /flags/:id
  def destroy
    if @challenge_flag.challenge.launch_docker?
      DockerLauncher.get_instance(@challenge_flag.docker_host_name).kill_challenge(@challenge_flag.challenge, @challenge_flag, @challenge_flag.user)
    end
    #user_id = @challenge_flag.user_id
    if @challenge_flag.destroy
      if @challenge_flag.user_id == current_user.id
        flash[:success] = "You have given up on challenge '#{@challenge_flag.challenge.name}'. Try again later!"
      else
        flash[:success] = "You have destroyed the flag for '#{@challenge_flag.challenge.name}'. This also killed any server associated with it."
      end
    else
      if @challenge_flag.user_id == current_user.id
        flash[:error] = "Challenge give up operation failed for challenge '#{@challenge_flag.challenge.name}'"
      else
        flag[:error] = "Challenge flag destruction failed for challenge '#{@challenge_flag.challenge.name}'. This may or may not have killed any associated servers."
      end
    end
    redirect_to :back
  end
end
