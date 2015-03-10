class Users::RegistrationsController < Devise::RegistrationsController
  def new
    logger.info "Devise new"
    @suggested_city_search_terms = US_CITIES
    super
  end

  def create
    logger.info "Devise create"
    params['user']['sign_up_ip'] = request.env['REMOTE_ADDR']
    if params['location']
      result = Geocoder.search(params['location'])
      if result.present? && result.first.country_code == 'US'
        params['user']['profile_attributes']['city'] = result.first.city
        params['user']['profile_attributes']['state'] = result.first.state_code
      end
    end
    super
  end

end
