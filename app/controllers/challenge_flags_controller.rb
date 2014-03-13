class ChallengeFlagsController < ApplicationController
  load_and_authorize_resource

  # DELETE /flags/:id
  def destroy
    user_id = @challenge_flag.user_id
    if @challenge_flag.destroy
      flash[:success] = 'Flag destroyed'
    else
      flash[:error] = 'Flag could not be destroyed'
    end
    redirect_to user_path(user_id)
  end
end
