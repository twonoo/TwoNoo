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
			#unless distance_from("Denver, CO") < 100 || distance_from("Pittsburgh, PA") < 100
			unless distance_from([39.737567,-104.9847179]) < 100 || distance_from("Pittsburgh, PA") < 100
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
		# Get Coordinates
    in_network = false

		logger.info "distance: " + Geocoder::Calculations.distance_between([39.737567,-104.9847179], location).to_s unless location.nil?

    unless location.nil?
      if Geocoder::Calculations.distance_between([39.737567,-104.9847179], location) < 100 || Geocoder::Calculations.distance_between([40.44062479999999, -79.9958864], location) < 100
        in_network = true
      end
    end

		results = Hash.new

		# Cycle Through Activity Types and Store Each 
		ActivityType.all.each do |a|
      if in_network
        result = where('datetime BETWEEN ? AND ?', Time.now.utc, Date.today + 15)
        .select('activities.*, COUNT(rsvps.id) as rsvp_count')
        .where(cancelled: false)
        .where(activity_types: {id: a.id})
        .within(25, origin: location)
        .joins(:rsvps)
        .joins(:activity_types)
        .group('rsvps.activity_id')
        .order('rsvp_count DESC')
        .limit(4)
        results["#{a.id}"] = result
      else
        result = where('datetime BETWEEN ? AND ?', Time.now.utc, Date.today + 15)
        .select('activities.*, COUNT(rsvps.id) as rsvp_count')
        .where(cancelled: false)
        .where(activity_types: {id: a.id})
        .joins(:rsvps)
        .joins(:activity_types)
        .group('rsvps.activity_id')
        .order('rsvp_count DESC')
        .limit(4)
        results["#{a.id}"] = result
      end

		end

		# Calculate Top Trending
    if in_network
      top = where('datetime BETWEEN ? AND ?', Time.now.utc, Date.today + 15)
      .select('activities.*, COUNT(rsvps.id) as rsvp_count')
      .where(cancelled: false)
      .within(25, origin: location)
      .joins(:rsvps)
      .joins(:activity_types)
      .group('rsvps.activity_id')
      .order('rsvp_count DESC')
      .limit(4)
      results['top'] = top
    else
      top = where('datetime BETWEEN ? AND ?', Time.now.utc, Date.today + 15)
      .select('activities.*, COUNT(rsvps.id) as rsvp_count')
      .where(cancelled: false)
      .joins(:rsvps)
      .joins(:activity_types)
      .group('rsvps.activity_id')
      .order('rsvp_count DESC')
      .limit(4)
      results['top'] = top
    end



		return results
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
