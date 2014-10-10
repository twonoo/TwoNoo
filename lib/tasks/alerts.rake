namespace :alerts do
	task :send_alerts => :environment do
		Alert.all.each do |a|
			activities = Activity.terms(a.keywords)
			activities = Activity.where(alerted: false)
	    activities = activities.within(a.distance, origin: a.location)
	    activities.each do |activity|
				a.user.notify('Activity Alert from TwoNoo!', "#{activity.activity_name} on #{activity.datetime.strftime("%A, %B %e, %Y @ %l:%M %p")}")
				activity.alerted = true
				activity.save!
				puts "#{a.user.email} was notified about #{activity.activity_name}"
			end
		end
	end
end