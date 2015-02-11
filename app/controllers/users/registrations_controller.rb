class Users::RegistrationsController < Devise::RegistrationsController
  def new
    logger.info "Devise new"
    super
  end

  def create
    logger.info "Devise create"
    params['user']['sign_up_ip'] = request.env['REMOTE_ADDR']
    super
  end

end
