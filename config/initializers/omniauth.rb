Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '508640691064-qtaddpu6k177crtm6ed4eher140gb999.apps.googleusercontent.com',
      '2MpNyC_RjDUdADBDQs752GLz', {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/calendar',
    redirect_uri:'http://dev-steve.twonoo.com/auth/google_oauth2/callback'
  }
end
