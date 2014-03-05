class ProfilePhoto < ActiveRecord::Base
  include UniquePhotoId
  
  before_destroy :delete_file
   
  def upload(image)
    self.generate_unique_photo_id
    self.PhotoId = self.PhotoId + File.extname(image.original_filename)
    File.open(Rails.root.join('app', 'assets', 'images', 'profile', self.PhotoId), 'wb') do |file|
      file.write(image.read)
    end
  end
  
  def delete_file
    path_to_file = Rails.root.join('app', 'assets', 'images', 'profile', self.PhotoId)
    
    File.delete(path_to_file) if File.exist?(path_to_file)
  end

end
