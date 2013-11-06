class UsersController < ApplicationController
  #layout :resolve_layout

  def welcome
    @user = current_user
  end

  def show
    @user = User.find(params[:id])
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
  
  private

    def user_params
      params.require(:user).permit(:FirstName, :LastName,
                                   :Email, :UserId,
                                   :password, :password_confirmation,
                                   :Birthday, :AboutMe)
    end
          
    def user_params_no_pass
      params.require(:user).permit(:FirstName, :LastName,
                                   :Email, :UserId,
                                   :Birthday, :AboutMe)
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
