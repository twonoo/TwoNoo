class Interest < ActiveRecord::Base

  has_many :interests_options
  has_and_belongs_to_many :users
  has_and_belongs_to_many :activities

  before_create :generate_code

  validates_uniqueness_of :name, :code

  default_scope { where(:active => true) }

  def interests_option_id(user_id)
    InterestsUser.where(user_id: user_id, interest_id: self.id).pluck(:interests_option_id).first
  end

  def interests_option_value(user_id)
    InterestsOption.where(id: interests_option_id(user_id)).pluck(:option_value).first
  end

  def interests_option_name(user_id)
    InterestsOption.where(id: interests_option_id(user_id)).pluck(:option_name).first
  end

  # For now, these images are manually put in the public/ folder.  In the future, we may want to
  # change this to be a paperclip field, so that the image can be updated in the admin interface, 
  # and also so the file names don't have to match the activity name.
  def default_image_exists?
    !!(Rails.application.assets.find_asset default_image_path)
  end

  # Default image file name is gotten by removing all white space from name, then turning all non
  # letter characters into underscores(_), then downcasing.
  # Example: Skiing - Cross Country becomes skiing_crosscountry
  def default_image_path
    "default_interest_images/#{name.gsub(/\s/,'').gsub(/\W/,'_').downcase}.jpg"
  end

  private

  def generate_code

    self.code = self.name.split.map { |w| w[0] }.join
    10.times.each do |val|
      unless Interest.exists? code: self.code.upcase
        break
      end
      self.code += val.to_s
    end

  end

end
