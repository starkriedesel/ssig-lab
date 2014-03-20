class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  # PUT /users/:id/add_challenge
  def add_challenge
    @user.completed_challenges << Challenge.find(params[:challenge_id])
    if @user.save
      flash[:success] = 'Added challenge record for user'
    else
      flash[:error] = 'Failed to add challenge record for user'
    end
    redirect_to @user
  end

  # DELETE /users/:id/clear_challenge/:challenge_id
  def clear_challenge
    if @user.completed_challenges.destroy(params[:challenge_id])
      @user.update_points
      flash[:success] = 'Cleared challenge record for user'
    else
      flash[:error] = 'Failed to clear challenge record for user'
    end
    redirect_to @user
  end
end
