class User < ActiveRecord::Base

  acts_as_messageable
  has_many :alerts
  has_one :profile, dependent: :destroy
  has_one :notification_setting
  has_many :follow_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :follow_relationships, source: :followed
  has_many :searches
  has_many :recommended_followers
  has_many :view_logs
  has_many :rsvps
  has_many :activities
  has_and_belongs_to_many :interests

  accepts_nested_attributes_for :profile

  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name: "FollowRelationship",
           dependent: :destroy
  has_many :followers, through: :reverse_relationships

  has_many :activities
  has_many :likes

  before_save :geocode_ip
  after_save :default_follow
  after_create :initial_credits

  default_scope { includes(:profile, :activities) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook]


  def initial_credits
    Transaction.create!(transaction_type_id: 3, user_id: id, amount: 5, balance: 5)

    # if the user was referred give the referrer 1 credit and make them followers of each other
    unless self.profile.referrer.nil?
      if self.profile.referrer > 0
        referrer = User.find_by_id(self.profile.referrer)
        unless referrer.nil?
          Transaction.create!(transaction_type_id: 7, user_id: referrer.id, amount: 1, balance: (Transaction.get_balance(referrer) + 1))
          self.follow!(referrer.id)
          referrer.follow!(self.id)

          # should probably see about adding in some notifications or something here
        end
      end
    end
  end

  def facebook_friends?(other_user)
    if self.provider == 'facebook' && other_user.provider == 'facebook' && other_user.fb_token.present?
      response = HTTParty.get("https://graph.facebook.com/v2.2/me/friends/#{self.uid}?access_token=#{other_user.fb_token}")
      if response.present?
        data_set = response.parsed_response
        return true if data_set['data'].present?
      end
    end
    false
  end

  def following?(other_user)
    follow_relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    follow_relationships.create!(followed_id: other_user) unless followed_user_ids.include?(other_user)
  end

  def unfollow!(other_user)
    follow_relationships.find_by(followed_id: other_user).destroy
  end

  def recommend_follow!(other_user, order, match_criteria, match_data=nil)
    recommended_followers.create!(
        recommended_follower_id: other_user.id,
        order: order,
        match_criteria: match_criteria,
        match_data: match_data
    ) unless RecommendedFollower.exists?(user_id: self.id, recommended_follower_id: other_user.id)
  end

  def self.from_omniauth(auth)

    #facebooks uid is not always the same any more, so in the event they return a different one, we need to look up the user by email.
    user = where(provider: 'facebook', uid: auth.uid).first
    user = where(email: auth.info.email).first if user.blank?

    if user.blank?

      user = new
      user.skip_confirmation!
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
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
      user.save

      logger.info "created account for facebook user: #{user.email}"

    end

    #These should always be updated on a new log in to ensure the token expiration is updated and to retrofit existing
    #users prior to this update.
    user.uid = auth.uid
    user.fb_token = auth.credentials[:token]
    user.fb_token_expires_in = auth.credentials[:expires_at]
    if auth.info.location.present?
      user.profile.update_location(auth.info.location, nil, true)
    end

    user
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

  def mailboxer_email(object)
    return self.email
  end

  def name
    return self.profile.first_name + ' ' + self.profile.last_name
  end

  def sign_up_ip=(ip)
    @sign_up_ip = ip
  end

  def geocode_ip
    if profile.city.nil? || profile.state.nil?
      logger.info "IP Address: #{current_sign_in_ip}"
      logger.info "IP Address: #{@sign_up_ip}"

      ip = (current_sign_in_ip.nil? ? @sign_up_ip : current_sign_in_ip)
      results = Geocoder.search(ip)
      logger.info "results: #{results}"

      result = results.first
      unless result.nil?
        logger.info "city: #{result.city}"
        logger.info "state: #{result.state_code}"

        if result.city.present? and result.state_code.present?
          profile.city = result.city
          profile.state = result.state_code
        end
      end
    end
  end

  def default_follow
    if profile.city.present? and profile.state.present?

      case profile.state
        when "CO"
          # user1 = User.find_by_id(2) #Keefe
          user2 = User.find_by_id(231) #TwoNoo Denver
          # follow!(2) unless (following?(user1) || (self == user1))
          follow!(231) unless (user2.nil? || following?(user2))
        when "AK"
          user1 = User.find_by_id(3) # Betts
          user2 = User.find_by_id(16) # TwoNoo Alaska
          follow!(3) unless (following?(user1) || (self == user1))
          follow!(16) unless (user2.nil? || following?(user2) || (self == user2))
        when "PA"
          user1 = User.find_by_id(4) # Eric
          user2 = User.find_by_id(241) # TwoNoo Pittsburgh
          follow!(4) unless (following?(user1) || (self == user1))
          follow!(241) unless (user2.nil? || following?(user2) || self == user1)
      end
    end
  end

  def find_people
    user_key = Digest::SHA1.hexdigest(user.id.to_s + WEB_SOCKET_CIPHER)
    PeopleFinder.new(self).find_by_all
    Fiber.new do
      WebsocketRails[:people_you_know].trigger user_key, 'done'
    end.resume
  end

end