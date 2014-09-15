class UsersController < ApplicationController

	def follow!
		current_user.follow!(params[:id])
		
		# notify the user that they are being followed
		current_user.notify(params[:id], 'is now following you.')

		redirect_to request.referer
	end

	def unfollow!
		current_user.unfollow!(params[:id])
		redirect_to request.referer
	end


end
