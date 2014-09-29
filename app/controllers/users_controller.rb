class UsersController < ApplicationController

	def follow!
		current_user.follow!(params[:id])
		
		# notify the user that they are being followed
		current_user.notify(params[:id], 'is now following you.')

		redirect_to profile_path(params[:id]), notice: "You're now following #{User.find(params[:id]).name}"
	end

	def unfollow!
		current_user.unfollow!(params[:id])
		redirect_to request.referer
	end


end
