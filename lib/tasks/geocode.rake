namespace :geocode do
	task :set_location_by_ip => :environment do
    Geocoder.configure(:tmeout => 6)
    User.all.each do |user|
      if (user.profile.city.nil? || user.profile.state.nil?) && !(user.current_sign_in_ip.nil?)
        puts "IP Address: #{user.current_sign_in_ip}"
        results = Geocoder.search(user.current_sign_in_ip)
        puts "results: #{results}"

        result = results.first
        unless result.nil?
          puts "city: #{result.city}"
          puts "state: #{result.state_code}"

          if result.city.present? && result.state_code.present?
            user.profile.city = result.city
            user.profile.state = result.state_code
            user.save
          end
        end
      end
    end
    Geocoder.configure(:tmeout => 3)
  end
end
