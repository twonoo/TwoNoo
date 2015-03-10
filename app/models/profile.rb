class Profile < ActiveRecord::Base
  belongs_to :user
  has_one :notification_setting

  validates :first_name, :last_name, length: {minimum: 2}
  # validates :gender, numericality: { only_integer: true }
  validate :must_be_18_or_older

  after_initialize :init

  after_save :create_notification_setting

  has_attached_file :profile_picture, :styles => {:medium => "300x300>", :thumb => "100x100#"}, :default_url => "#{ENV['BASEURL']}/no-image.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  def must_be_18_or_older
    if birthday.present? && birthday > Date.today - 6570
      errors.add(:birthday, 'Sorry, you must be 18 years or older to use TwoNoo')
    end
  end

  def update_location(location, skip_write = false)
    result = Geocoder.search(location)
    if result.present? && result.first.country_code.downcase == 'us'
      self.city = result.first.city
      self.state =  result.first.state_code
      self.save unless skip_write
    else
      false
    end
  end

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

end
