class User < ActiveRecord::Base
  acts_as_messageable

  has_one :profile, dependent: :destroy
  has_many :follow_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :follow_relationships, source: :followed
  accepts_nested_attributes_for :profile

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "FollowRelationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships

  has_many :activities

  default_scope { includes(:profile, :activities) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook]


  def following?(other_user)
    follow_relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    follow_relationships.create!(followed_id: other_user)
  end

  def unfollow!(other_user)
    follow_relationships.find_by(followed_id: other_user).destroy
  end

  def self.from_omniauth(auth)
  where(auth.slice(:provider, :uid)).first_or_create do |user|
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    # Begin Profile Build
    user.build_profile
    user.profile.first_name = auth.info.first_name
    user.profile.last_name = auth.info.last_name
    if auth.extra.raw_info.gender == "male"
      user.profile.gender = 0
    else
      user.profile.gender = 1
    end
    oauth_picture = URI.parse(URI.encode(auth.info.image)) if auth.info.image?
    user.profile.profile_picture = oauth_picture
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.build_profile
        user.email = data["email"] if user.email.blank?
        user.profile.first_name = data["first_name"] if user.profile.first_name.blank?
        user.profile.last_name = data["last_name"] if user.profile.last_name.blank?
        user.profile.profile_picture = URI.parse(URI.encode(session["devise.facebook_data"]["info"]["image"])) if user.profile.profile_picture.blank?
        logger.info data
        if data["gender"] == "male"
          user.profile.gender = 0
        else
          user.profile.gender = 1
        end
      end
    end
  end

  def name
    return self.profile.first_name + ' ' + self.profile.last_name
  end

  def mailboxer_email(object)
    return self.email
  end

end
