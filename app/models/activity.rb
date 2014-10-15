class Activity < ActiveRecord::Base
	acts_as_commentable

	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x75>", :map_image => "250x100#", :trending => "650x500#" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
	belongs_to :user
	has_and_belongs_to_many :activity_types
	geocoded_by :address
	before_validation :geocode
	before_save :assign_timezone
	has_many :rsvps


	validates :activity_name, :datetime, :city, :state, :description, presence: true
	validate :distance_cannot_be_greater_than_100_miles

	acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

	def address
		[street_address_1, street_address_2, city, state].grep(String).join(', ')
	end

	def distance_cannot_be_greater_than_100_miles
		unless city.blank?
			unless distance_from("Denver, CO") < 100 || distance_from("Pittsburgh, PA") < 100
				errors[:base] << "Whoops! #{city} is not within our current network, but will be soon!"
			end
		end
	end

	def self.terms(terms)
		query = []
		terms.split.each do |t|
			query << "(activity_name LIKE '%#{t}%' OR location_name LIKE '%#{t}%' OR description LIKE '%#{t}%')"
		end
		where(query.join(" AND "))
	end

	def self.trending(location)
		where('datetime BETWEEN ? AND ?', Time.now.utc, Date.today + 15).where('cancelled IS FALSE').within(25, origin: Geocoder.search(location).first.coordinates).joins(:rsvps).group(:activity_id).count
	end

	private
	def assign_timezone
		timezone = Timezone::Zone.new(:latlon => fetch_coordinates)
		#offset = timezone.utc_offset.abs
		#db_offset = 21600
		#offset = offset - 3600 if Time.now.dst?
		self.tz = timezone.active_support_time_zone
		#self.datetime = self.datetime - offset
		#logger.info "     !!!!_____!_!_!_!_!__!     #{self.datetime}"
	end

end
