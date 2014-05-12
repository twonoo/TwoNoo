class UsersController < ApplicationController
  #layout :resolve_layout

  def dashboard
    @user = User.find(params[:id])
    
    @activities = Activity.where("CreateUserId = ?", @user.id)
    @followings = Following.where("user_id1 = ?", @user.id)
    @followingMes = Following.where("user_id2 = ?", @user.id)
    
  end

  def followUser
    @user = current_user
    @userToFollow = User.find(params[:UserId])
    
    #Make sure they aren't both null
    unless @user.nil? && @userToFollow.nil?
      @following = Following.new
      @following.user_id1 = @user.id
      @following.user_id2 = @userToFollow.id
      @following.save
    end
    
  end
  
  def messages
    @user = User.find(params[:id])
  end

  def settings
    @user = User.find(params[:id])
  end

  def welcome
    @user = current_user
  end

  def profilePictureUpdate
    @user = current_user  
 
    #Get the Primary photo ID
    @mainPhoto = ProfilePhoto.where("Users_id = ? AND MainPhoto = ?", @user.id, true).first
    @photo = ProfilePhoto.find(params[:PhotoId])

    if params[:todo] == "delete"
      @photo = ProfilePhoto.find(params[:PhotoId])
      @photo.destroy
    else
      #Update all photos to NOT be the primary
      unless @mainPhoto.nil?
        @mainPhoto.MainPhoto = false
        @mainPhoto.save
      end
      
      #Update the new photo be the primary
      unless @photo.nil?
        @photo.MainPhoto = true
        @photo.save
      end
      
    end
    
    #If it did not succeed the set the orignal photo back to primary and somehow let the user know.
    redirect_to :action => :show, :id => @user.id
        
  end

  def profilePictureUpload
    @user = current_user  
 
    if params[:profilePicture][:picture]
      uploaded_io = params[:profilePicture][:picture]
      @profilePhoto = ProfilePhoto.new
      @profilePhoto.Users_id = @user.id
      @profilePhoto.MainPhoto = false
      @profilePhoto.upload(uploaded_io)
      @profilePhoto.save
    end
    
    redirect_to :action => :show, :id => @user.id
  end
  
  def update
    @user = User.find(params[:id])
    
    @user.should_validate_password = params[:orig_password].length > 0
    
    if !@user.update_attributes(user_params)
      flash.now[:error] = @user.errors.full_messages
    end
    
    render 'show'
     
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      sign_in @user

      flash[:success] = "Welcome to TwoNoo!"
      redirect_to welcome_user_path(@user)
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])

    # Get the photos for the Activity
    @profilePhotos = ProfilePhoto.where("Users_id = ?", @user.id)
  end

  def showUser
    @user = User.find(params[:id])
  end
  
  def unfollowUser
    @user = current_user
    @userToFollow = User.find(params[:UserId])

    Following.where("user_id1 = ? and user_id2 = ?", @user.id, @userToFollow.id).destroy_all
    
    redirect_to :action => :dashboard, :id => @user.id
  end
    
  private

    def user_params
      params.require(:user).permit(:FirstName, :LastName,
                                   :Email, :UserId,
                                   :password, :password_confirmation,
                                   :Birthday, :AboutMe,
                                   :Sex)
    end
          
    def user_params_no_pass
      params.require(:user).permit(:FirstName, :LastName,
                                   :Email, :UserId,
                                   :Birthday, :AboutMe,
                                   :Sex)
    end
    
    def resolve_layout
      case action_name
      when "welcome"
        "welcome"
      else
        "application"
      end
    end
end
