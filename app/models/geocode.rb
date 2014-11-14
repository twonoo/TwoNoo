class Geocode < ActiveRecord::Base
	after_initialize :init

	def init
	end

  def self.coordinates(city, state)
    geocode = where(city: city).where(state: state).first

    # we don't have the latlon
    unless geocode.nil? then
      latitude = geocode.latitude
      longitude = geocode.longitude
    else
      # Look up the latlong by citysate
      search_coordinates = Geocoder.search(params[:location]).first.coordinates

      latitude = search_coordinates.latitude
      longitude = search_coordinates.longitude
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

    coords = [latitude, longitude]

    return coords
  end
end
