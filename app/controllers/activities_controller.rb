class ActivitiesController < ApplicationController
  layout :resolve_layout

  # This is the main activities page for searching on activites.
  # When first loaded it will display all of the activities for the user's location for today.
  # The user will then have the option to update the search criteria
  # If the user clickes on the "What's Hot" link this will be called with the param 'hot'
  # which will then load all the activities that meet ????? criteria
  def index
    @searchClause = ""
    @searchParams = []
    @first = true
    @bActivityDate = false
    
    if !(params[:activity_search].nil?)
      params[:activity_search].each do |key, value|
        if !(params[:activity_search][key].nil? or params[:activity_search][key].empty?)      
          if key == "ActivityDate"
            @bActivityDate = true
          end
          @searchParams << [key + " LIKE ?", "%#{params[:activity_search][key]}%"]
        end
      end   
    end
    
    unless @bActivityDate
      @date = Time.now
      
      @searchParams << ["ActivityDate is null OR ActivityDate = ?", @date.strftime("%Y-%m-%d")]
    end
      
    @joins = ""
    @where = ""
    
    if !(params[:username].nil? or params[:username].empty?) 
      @joins = "INNER JOIN users on users.id = activities.CreateUserId "
      @where = "users.UserId LIKE '%" + params[:username] + "%' "
    end
    
    unless params[:Following].nil?
      @joins = @joins + "INNER JOIN followings on followings.user_id2 = activities.CreateUserId "
      
      unless @where.empty?
        @where = @where + "AND "
      end
      
      @where = @where + "followings.user_id1 = " + current_user.id.to_s + " "
    end
    
    unless @joins.empty? and @where.empty?
      unless @searchParams.size == 0
        @activities = Activity.joins(@joins).where(@where).all :conditions => [@searchParams.map{|c| c[0] }.join(" AND "), *@searchParams.map{|c| c[1..-1] }.flatten]
      else
        @activities = Activity.joins(@joins).where(@where).all
      end
    else
       #@activities = Activity.joins(:activity_types).where("activity_type_id = ?", params[:activityTypes])
      unless @searchParams.size == 0
        @activities = Activity.all :conditions => [@searchParams.map{|c| c[0] }.join(" AND "), *@searchParams.map{|c| c[1..-1] }.flatten]
      else
      #      @activities = Activity.joins(:activity_types).where("activity_type_id = ?", params[:activityTypes])
        @activities = Activity.all 
      end
        
    end
    
      # @activities = Activity.joins(:activity_types).where("activity_type_id = ?", params[:activityTypes])
    
    # if !(params[:Following].nil? or params[:Following].empty?) 
        # @activities = Activity.joins("INNER JOIN followings on followings.user_id2 = activities.CreateUserId").where("followings.user_id1 = ?", current_user.id)
    # end
    
    @activityTypes = ActivityType.all
    
    
  end
  
  def show
    @activity = Activity.find(params[:id])
    
    @user = User.find(@activity.CreateUserId)
    @profilePhoto = ProfilePhoto.where("Users_id = ? AND MainPhoto = ?", @user.id, true).first
    
    # Get the photos for the Activity
    @mainPhoto = PhotoActivity.where("Activity_Id = ? AND MainPhoto = ?", @activity.id, true).first
  end
  
  def new
    @activity = Activity.new
    @activityTypes = ActivityType.all
  end
  
  def edit
     @activity = Activity.find(params[:id])
  end
  
  def create
    @activity = Activity.new(activity_params)
    @activity.ModUserId = @activity.CreateUserId = current_user.id
    
    # For each ActivityType, let's create a new activity Type record
    params[:activityType].each do |value|
      @activity.activity_types << ActivityType.find(value)
    end

      if @activity.save
      if params[:activity][:picture]
        uploaded_io = params[:activity][:picture]
        @photoActivity = PhotoActivity.new
        @photoActivity.Activity_id = @activity.id
        @photoActivity.MainPhoto = true
        @photoActivity.upload(uploaded_io)
        @photoActivity.save
      end
     
      
#      File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
#        file.write(uploaded_io.read)
#      end
    
      flash[:success] = "Activity Created!"
      redirect_to activity_path(@activity)
    else
      render 'new'
    end
  end
  
  def update
     @activity = Activity.find(params[:id])
    
    if @activity.update(activity_params)
      flash[:success] = "Activity Updated!"
      redirect_to activity_path(@activity)
    else
      render 'edit'
    end end
  
  private

    def activity_params
      params.require(:activity).permit(:Name,
                                       :ActivityDate,
                                       :City,
                                       :State,
                                       :StreetAddress1,
                                       :StreetAddress2,
                                       :Country,
                                       :LocationName,
                                       :Description,
                                       :rsvp,
                                       :Website)
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
