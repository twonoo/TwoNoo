namespace :alerts do
	task :send_alerts => :environment do
		Alert.all.each do |a|
			activities = Activity.terms(a.keywords)
	    activities = activities.where('datetime < DATE_ADD(NOW(), INTERVAL 14 DAY)')
	    activities = activities.within(a.distance, origin: a.location)
	    activities.each do |activity|
				a.user.notify('Activity Alert from TwoNoo!', "#{activity.activity_name} on #{activity.datetime.strftime("%A, %B %e, %Y @ %l:%M %p")}")
			end
		end
	end
end
