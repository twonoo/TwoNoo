namespace :reports do
  task :send_stats_report => :environment do
    stats_report()
  end
end

  def stats_report
    number_of_new_activities = Activity.where("created_at > '#{DateTime.now.beginning_of_day}'").count
    number_of_new_profiles = Profile.where("created_at > '#{DateTime.now.beginning_of_day}'").count
    number_of_cancelled_users = Profile.where("closed_at > '#{DateTime.now.beginning_of_day}'").count

    # Mandrill integration
    mandrill_to = [{:email => "skeefe15@gmail.com", :type => 'to'}]
    mandrill = Mandrill::API.new
    template = 'admin_stats_report'
    tc = [{"name" => "twonoo", "content" => "TwoNoo"}]
    message = {  
     :to=>mandrill_to,  
     :merge_language=>"mailchimp",
     :global_merge_vars=>[
      {"name"=>"STATS_DAY", "content"=>Date.current.strftime('%B %d, %Y')},
      {"name"=>"STATS_TIME", "content"=>Time.now.strftime('%l:%M %P')},
      {"name"=>"NUMBER_OF_NEW_ACTIVITIES", "content"=>number_of_new_activities},
      {"name"=>"NUMBER_OF_NEW_PROFILES", "content"=>number_of_new_profiles},
      {"name"=>"NUMBER_OF_CANCELLED_USERS", "content"=>number_of_cancelled_users}
      ]
    }  

    sending = mandrill.messages.send_template template, tc, message  
    puts sending
  end
