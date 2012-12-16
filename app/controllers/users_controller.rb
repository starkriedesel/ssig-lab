class UsersController < ApplicationController
	before_filter :find_model

	def show
	end
	
	def admin_challenge_edit
	end

	private
	def find_model
		@user = User.find(params[:id]) if params[:id]
	end
end