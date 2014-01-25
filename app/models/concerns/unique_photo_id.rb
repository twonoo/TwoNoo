module UniquePhotoId
  extend ActiveSupport::Concern

  included do
    before_create :generate_unique_photo_id
  end

  protected

  def generate_unique_photo_id
    self.PhotoId = loop do
      random_PhotoId = SecureRandom.urlsafe_base64(nil, false)
      break random_PhotoId unless self.class.exists?(PhotoId: random_PhotoId)
    end
  end
end