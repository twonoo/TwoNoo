Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '18950285410-066kiriporohq1c426q4hdhldqrbohvu.apps.googleusercontent.com',
      'vD_9BiLj-oD7WlHR47IBy6Cw', {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/calendar',
    redirect_uri:'https://www.twonoo.com/auth/google_oauth2/callback'
  }
end
