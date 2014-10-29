namespace :test do
  require 'mandrill'

	task :send_test => :environment do
    m = Mandrill::API.new
    message = {  
     :subject=> "Hello from the Mandrill API",  
     :from_name=> "TwoNoo",  
     :text=>"Hi message, how are you?",  
     :to=>[  
       {  
         :email=> "steven.betts@gmail.com",  
         :name=> "Steven"  
       }  
     ],  
     :html=>"<html><h1>Hi <strong>message</strong>, how are you?</h1></html>",  
     :from_email=>"no-reply@yourdomain.com"  
    }  
    sending = m.messages.send message  
    puts sending
	end

	task :send_template_test => :environment do
    m = Mandrill::API.new
    t = 'twonoo_invite'
    tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
    message = {  
     :from_name=> "TwoNoo",  
     :to=>[  
       {  
         :email=> "steven.betts@gmail.com",  
         :name=> "Steven"  
       }  
     ],  
     :from_email=>"no-reply@twonoo.com",
     :merge_language=>"mailchimp",
     :global_merge_vars=>[{"name"=>"INVITER", "content"=>"TwoNoo Tester Inviter"}] 
    }  
    sending = m.messages.send_template t, tc, message  
    puts sending
	end
end
