namespace :alerts do
	task :send_alerts => :environment do
		Alert.all.each do |a|
			activities = Activity.terms(a.keywords)
	    activities = activities.where('datetime < DATE_ADD(NOW(), INTERVAL 14 DAY)')
	    #activities = activities.within(params[:miles], origin: search_location)
	    activities.each do |activity|
				a.user.notify('New Alert', "#{activity.activity_name}... you should totes go!")
			end
		end
	end
end
