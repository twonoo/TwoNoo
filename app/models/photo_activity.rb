class PhotoActivity < ActiveRecord::Base
  include UniquePhotoId
  
   
  def upload(image)
    self.generate_unique_photo_id
    File.open(Rails.root.join('public', 'uploads', self.PhotoId), 'wb') do |file|
      file.write(image.read)
    end
  end
end
