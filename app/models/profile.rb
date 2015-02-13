class Profile < ActiveRecord::Base
  belongs_to :user
  has_one :notification_setting

  validates :first_name, :last_name, length: {minimum: 2}
  # validates :gender, numericality: { only_integer: true }
  validate :must_be_18_or_older

  after_initialize :init

  after_save :create_notification_setting

  has_attached_file :profile_picture, :styles => {:medium => "300x300>", :thumb => "100x100#"}, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  def must_be_18_or_older
    if birthday.present? && birthday > Date.today - 6570
      errors.add(:birthday, "Sorry, you must be 18 years or older to use TwoNoo")
    end
  end

  def self.terms(terms)
    query = []
    interest_ids = []
    terms.split.each do |t|
      query << "(first_name LIKE '%#{t}%' OR last_name LIKE '%#{t}%')"
      interest_ids << Interest.where('name like ?', "%#{t}%").select(:id).pluck(:id)
    end

    user_ids = InterestsUser.where('interest_id in (?)', interest_ids.flatten).select(:user_id).pluck(:user_id)
    query = query.join(" AND ")
    query << " OR user_id IN (#{user_ids.join(',')})" unless user_ids.blank?

    where(query) unless query.blank?
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
