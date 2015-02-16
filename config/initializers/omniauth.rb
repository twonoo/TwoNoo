Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'],
           {
               access_type: ENV['GOOGLE_ACCESS_TYPE'],
               scope: ENV['GOOGLE_SCOPE'],
               redirect_uri: ENV['GOOGLE_REDIRECT_URI']
           }
end

