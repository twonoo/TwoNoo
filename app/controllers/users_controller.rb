class UsersController < ApplicationController

	def follow!
		current_user.follow!(params[:id])

		followed_user = User.find(params[:id])
		
		# notify the user that they are being followed
		followed_user.notify("You have a new follower!", "#{current_user.name} is now following you.")

		redirect_to profile_path(params[:id]), notice: "You're now following #{followed_user.name}"
	end

	def unfollow!
		current_user.unfollow!(params[:id])
		redirect_to request.referer
	end


end
