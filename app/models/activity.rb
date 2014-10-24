class Activity < ActiveRecord::Base
	acts_as_commentable

	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x75>", :map_image => "250x100#", :trending => "650x500#" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
	belongs_to :user
	has_and_belongs_to_many :activity_types
	#geocoded_by :address
	before_validation :geocodecache
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
      denver = [39.737567, -104.9847179]
      pittsburgh = [40.44062479999999, -79.9958864]
      fairbanks = [64.8377778, -147.7163889]

			#unless distance_from("Denver, CO") < 100 || distance_from("Pittsburgh, PA") < 100
			unless (distance_from(denver) < 100 || distance_from(pittsburgh) < 100 || distance_from(fairbanks) < 100) then
				errors[:base] << "Whoops! #{city} is not within our current network, but will be soon!" + distance_from(fairbanks).to_s
			end
		end
	end

  def geocodecache
    logger.info "geocodecache"
    geocode = Geocode.where(city: city).where(state: state).first

    if latitude.blank? || longitude.blank?
      # for some reason we don't have the latlon
      unless geocode.nil? then
        self.latitude = geocode.latitude
        self.longitude = geocode.longitude
      else
        # Look up the latlong by citysate
        search_coordinates = Geocoder.search(params[:location]).first.coordinates

        self.latitude = search_coordinates.latitude
        self.longitude = search_coordinates.longitude
      end
    end

    if geocode.nil? then
      # let's assume we don't have the timezone
      timezone = Timezone::Zone.new(:latlon => [latitude, longitude])

      # insert the geocode
      geocode = Geocode.new(city: city, state: state, latitude: latitude, longitude: longitude,
                  timezone: timezone.active_support_time_zone)

      logger.info "save it"
      geocode.save
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

    unless location.nil?
      denver = [39.737567, -104.9847179]
      pittsburgh = [40.44062479999999, -79.9958864]
      fairbanks = [64.8377778, -147.7163889]

      if (Geocoder::Calculations.distance_between(denver, location) < 100 ||
          Geocoder::Calculations.distance_between(pittsburgh, location) < 100 ||
          Geocoder::Calculations.distance_between(fairbanks, location) < 100)
      then
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

  def get_coordinates
    unless self.latitude.nil? or self.longitude.nil? then
      return [self.latitude, self.longitude]
    end

    return fetch_coordinates
  end

  def get_timezone
    # first, see if the timezone is already in the db
    geocode = Geocode.where(latitude: latitude).where(longitude: longitude).first

    if geocode.nil? then
      # we had a cache miss
		  zone = Timezone::Zone.new(:latlon => get_coordinates)
      timezone = zone.active_support_time_zone
    else
      return geocode.timezone
    end

    return timezone
  end
  
	def assign_timezone
		self.tz = get_timezone
	end

end
