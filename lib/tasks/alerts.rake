namespace :alerts do
	task :send_alerts => :environment do
    # ideally we want to roll through these by user id so we can send a single e-mail to the user with all of the activities that match
    # any of their alerts
		Alert.all.each do |a|
			activities = Activity.terms(a.keywords)
			activities = activities.where("created_at > ?", a.updated_at)
	    activities = activities.within(a.distance, origin: a.location)

      # We need to roll these up. maybe we add the notifications, but we need to summarize all the activities that match the alert
	    activities.each do |activity|
				a.user.notify('Activity Alert from TwoNoo!', "#{activity.activity_name} on #{activity.datetime.strftime("%A, %B %e, %Y @ %l:%M %p")}")
				UserMailer.delay.alert(a.user, activity, a)
				puts "#{a.user.email} was notified about #{activity.activity_name}"
			end
      a.updated_at = Time.now
      a.save!
		end
	end
end
