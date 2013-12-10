class DayValidator < ActiveModel::EachValidator
  
end

class User < ActiveRecord::Base
  has_many :activities
  
  before_save { self.Email = self.Email.downcase }
  before_save { self.UserId = self.UserId.downcase }
  
  validates :FirstName, presence: true, length: { maximum: 50 }
  validates :LastName, presence: true, length: { maximum: 50 }
  validates :UserId, presence: true,
                     length: { maximum: 50 },
                     uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :Email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }, :if => :should_validate_password?

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  attr_accessor :should_validate_password
  
  private

    def should_validate_password?
      @should_validate_password || new_record?
    end
    
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
