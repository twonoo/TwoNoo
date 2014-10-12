class Profile < ActiveRecord::Base
	belongs_to :user
	has_one :notification_setting

	validates :first_name, :last_name, length: { minimum: 2 }
	# validates :gender, numericality: { only_integer: true }
	validate :must_be_18_or_older

	after_initialize :init

	has_attached_file :profile_picture, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

	def must_be_18_or_older
		if birthday.present? && birthday > Date.today - 6570
			errors.add(:birthday, "Sorry, you must be 18 years or older to use TwoNoo")
		end
	end

	def init
		self.gender  ||= 3
	end

end
