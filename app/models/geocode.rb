class Geocode < ActiveRecord::Base
	after_initialize :init

	def init
	end

  def self.coordinates(city, state)
    geocode = where(city: city, state: state).first

    # we don't have the latlon
    unless geocode.nil? then
      logger.info "we have a hit"
      latitude = geocode.latitude
      longitude = geocode.longitude
    else
      logger.info "we do NOT have a hit"
      # Look up the latlong by citysate
      search_coordinates = Geocoder.search("#{city}, #{state}").first.coordinates
      logger.info "search_location: #{search_coordinates}"

      latitude = search_coordinates[0]
      longitude = search_coordinates[1]
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

  def self.coordinates_by_ip(ip_address)
    results = Geocoder.search(ip_address)
    logger.info "results: #{results}"

    result = results.first
    unless result.nil?
      logger.info "city: #{result.city}"
      logger.info "state: #{result.state_code}"

      if result.city.present? and result.state_code.present?
        coords = coordinates(result.city, result.state)
        return coords
      end
    end

    return nil
  end
end
