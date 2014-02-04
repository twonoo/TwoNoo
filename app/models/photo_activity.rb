class PhotoActivity < ActiveRecord::Base
  include UniquePhotoId
  
   
  def upload(image)
    self.generate_unique_photo_id
    self.PhotoId = self.PhotoId + File.extname(image.original_filename)
    File.open(Rails.root.join('app', 'assets', 'images', 'activity', self.PhotoId), 'wb') do |file|
      file.write(image.read)
    end
  end
end
