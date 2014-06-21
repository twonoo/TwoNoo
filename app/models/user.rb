class DayValidator < ActiveModel::EachValidator
  
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_many :activities

  
  before_save { self.email = self.email.downcase }
  before_save { self.UserId = (self.UserId.nil?) ? nil : self.UserId.downcase }
  
  validates :FirstName, presence: true, length: { maximum: 50 }
  validates :LastName, presence: true, length: { maximum: 50 }
  validates :UserId, presence: true,
                     length: { maximum: 50 },
                     uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  #has_secure_password
  #validates :password, length: { minimum: 6 }, :if => :should_validate_password?

  #def User.new_remember_token
  #  SecureRandom.urlsafe_base64
  #end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name:auth.extra.raw_info.name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20],
                          )
      end    end
  end
  
  #attr_accessor :should_validate_password
  
  private

  #  def should_validate_password?
  #    @should_validate_password || new_record?
  #  end
    
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
