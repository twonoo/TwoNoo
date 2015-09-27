class Profile < ActiveRecord::Base
  belongs_to :user
  has_one :notification_setting

  validates :first_name, :last_name, length: {minimum: 2}
  # validates :gender, numericality: { only_integer: true }
  validate :must_be_18_or_older

  after_initialize :init

  before_save :update_lat_lon
  after_save :create_notification_setting

  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :city_state_latitude,
                   :lng_column_name => :city_state_longitude

  has_attached_file :profile_picture, :styles => {:medium => "300x300>", :thumb => "100x100#"}, :default_url => "#{ENV['BASEURL']}/no-image.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/
  validates :closed_reason, length: { maximum: 255 }

  time_for_a_boolean :closed

  def must_be_18_or_older
    if birthday.present? && birthday > Date.today - 6570
      errors.add(:birthday, 'Sorry, you must be 18 years or older to use TwoNoo')
    end
  end

  def update_location(location, neighborhood = nil, skip_write = false)
    if neighborhood.present?
      self.neighborhood = neighborhood
    end

    result = Geocoder.search(location)
    if result.present? && result.first.country_code.downcase == 'us'
      self.city = result.first.city
      self.state =  result.first.state_code
    end

    if self.changed?
      self.save unless skip_write
    else
      false
    end
  end

  def self.having_interests(searched_interest_ids)
    # searched_interest_ids is an array of integers, so it cannot be an injection attack.
    if searched_interest_ids.present?
      joins(:user => :interests).where("interests.id IN (#{searched_interest_ids.map(&:to_i).map(&:to_s).join(',')})").uniq
    else
      where("1=0") #If no interests are passed in, we want to not return any profiles
    end
  end

  # This is a SQL injection vulnerability.  We need to take this out.
  def self.terms(terms)

    if terms.present?

      query = []
      interests_query = []
      options_query = []

      terms.split.each do |t|
        query << "(first_name LIKE '%#{t}%' OR last_name LIKE '%#{t}%')"
        interests_query << "(name LIKE '%#{t}%')"
        options_query << "(option_value LIKE '%#{t}%')"
      end

      interests_query = interests_query.join(' OR ')
      options_query = options_query.join(' OR ')

      interest_ids = Interest.where(interests_query).pluck(:id)
      interest_option_ids = InterestsOption.where(options_query).pluck(:id)

      user_ids = InterestsUser.where('interest_id in (?) or interests_option_id in (?)',
                                     interest_ids.flatten.uniq, interest_option_ids.flatten.uniq).pluck(:user_id)

      query = query.join(' AND ')
      query << " OR user_id IN (#{user_ids.uniq.join(',')})" unless user_ids.blank?
      query << " AND closed_at IS NULL"

      where(query) unless query.blank?

    end

  end

  def init
    self.gender ||= 3
  end

  def create_notification_setting
    if self.notification_setting.nil?
      self.notification_setting = NotificationSetting.new
    end
  end

  def update_lat_lon
    if city_changed? || state_changed? || city_state_latitude.blank? || city_state_longitude.blank?
      coords = Geocode.coordinates(city, state) rescue [nil,nil]
      self.city_state_latitude = coords[0]
      self.city_state_longitude = coords[1]
    end
  end
end
