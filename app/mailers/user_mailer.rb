class UserMailer < ActionMailer::Base
  require 'mandrill'

  include ActionView::Helpers::UrlHelper

ActionMailer::Base.default_url_options[:host] = "www.twonoo.com"


  default from: "no-reply@twonoo.com"

  def twonoo_invite(user, emails)
    @user = user
    #attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")

    #mail(bcc: emails, subject: "#{@user.name} has invited you to join TwoNoo!")
    # Mandrill integration

    @emails = emails.split(',')
    mandrill_to = @emails.map{|email| {:email => email, :type => 'bcc'}}
    m = Mandrill::API.new
    t = 'twonoo_invite'
    tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
    message = {  
     :from_name=> user.name,  
     :to=>mandrill_to,  
     :from_email=>"no-reply@twonoo.com",
     :merge_language=>"mailchimp",
     :global_merge_vars=>[
      {"name"=>"INVITER", "content"=>user.name},
      {"name"=>"ROOT_URL", "content"=>"#{link_to('TwoNoo', 'https://www.twonoo.com/?referrer=' + @user.id.to_s)}"},
      {"name"=>"SIGNUP_URL", "content"=>"#{link_to('Sign Up', 'https://www.twonoo.com/users/signup?referrer=' + @user.id.to_s)}"},
      {"name"=>"REFERRER", "content"=>@user.id.to_s}
      ] 
    }  

    sending = m.messages.send_template t, tc, message  
    logger.info sending

  end

  def feedback_from_user(user, feedback)
    @user = user
#    @feedback = feedback
#    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#
#    mail(to: "feedback@twonoo.com",
#      subject: "#{@user.name} has sent you feedback.",
#      template_name: "feedback")
    # Mandrill integration

    mandrill_to = [{:email => 'feedback@twonoo.com', :type => 'to'}]
    m = Mandrill::API.new
    t = 'feedback_from_user'
    tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
    message = {  
     :from_name=> user.name,  
     :to=>mandrill_to,  
     :from_email=>user.email,
     :merge_language=>"mailchimp",
     :global_merge_vars=>[
      {"name"=>"USER_NAME", "content"=>user.name},
      {"name"=>"FEEDBACK", "content"=>feedback}
      ] 
    }  

    sending = m.messages.send_template t, tc, message  
    logger.info sending
  end

  def feedback(feedback)
#    @feedback = feedback
#    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#
#    mail(to: "feedback@twonoo.com", subject: "Somebody has sent you feedback.")
    # Mandrill integration

    mandrill_to = [{:email => 'feedback@twonoo.com', :type => 'to'}]
    m = Mandrill::API.new
    t = 'feedback'
    tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
    message = {  
     :to=>mandrill_to,  
     :merge_language=>"mailchimp",
     :global_merge_vars=>[
      {"name"=>"FEEDBACK", "content"=>feedback}
      ] 
    }  

    sending = m.messages.send_template t, tc, message  
    logger.info sending
  end

  def activity_invite(user, activity, emails)
    @user = user
#    @activity = activity
#    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#
#    mail(bcc: emails, subject: "#{@user.name} has invited you to #{@activity.activity_name}!")
    # Mandrill integration

    @emails = emails.split(',')
    mandrill_to = @emails.map{|email| {:email => email, :type => 'bcc'}}
    m = Mandrill::API.new
    t = 'activity_invite'
    tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
    message = {  
     :from_name=> user.name,  
     :to=>mandrill_to,  
     :from_email=>"no-reply@twonoo.com",
     :merge_language=>"mailchimp",
     :global_merge_vars=>[
      {"name"=>"INVITER", "content"=>user.name},
      {"name"=>"ACTIVITY_ID", "content"=>activity.id},
      {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name},
      {"name"=>"ACTIVITY_DESC", "content"=>activity.description},
      {"name"=>"REFERRER", "content"=>@user.id.to_s}
      ] 
    }  

    sending = m.messages.send_template t, tc, message  
    logger.info sending

  end

  def new_follower(user, follower)
    @user = user

    if (@user.profile.notification_setting.new_follower)
#      @follower = follower
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@follower.name} is now following you.")
      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'new_follower'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> follower.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"FOLLOWER_ID", "content"=>follower.id},
        {"name"=>"FOLLOWER_NAME", "content"=>follower.name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def new_message(user, sender, message)
    @user = user

    if (@user.profile.notification_setting.new_message)
#      @message = message
#      @sender = sender
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "You have a new message from #{@sender.name}")

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'new_message'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> sender.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"MESSAGE", "content"=>message},
        {"name"=>"MESSAGER_NAME", "content"=>sender.name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def new_rsvp(user, attendee, activity)
    @user = user

    if (@user.profile.notification_setting.new_rsvp)
#      @attendee = attendee
#      @activity = activity
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@attendee.name} is joining #{@activity.activity_name}")
      
      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'new_rsvp'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> attendee.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"ATTENDEE", "content"=>attendee.name},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def new_following_activity(user, organizer, activity)
    @user = user

    if (@user.profile.notification_setting.new_following_activity)
#      @organizer = organizer
#      @activity = activity
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@organizer.name} just created #{@activity.activity_name} on TwoNoo!")

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'new_following_activity'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> organizer.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"ORGANIZER", "content"=>organizer.name},
        {"name"=>"ORGANIZER_ID", "content"=>organizer.id},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def attending_activity_update(user, activity)
    @user = user

    if (@user.profile.notification_setting.attending_activity_update)
#      @activity = activity
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@activity.activity_name} has been updated on TwoNoo!")

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'attending_activity_update'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> organizer.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def comment_on_owned_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_owned_activity)
#      @activity = activity
#      @commenter = commenter
#      @comment = comment
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'comment_on_owned_activity'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> commenter.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"COMMENTER_NAME", "content"=>commenter.name},
        {"name"=>"COMMENTER_ID", "content"=>commenter.id},
        {"name"=>"COMMENT", "content"=>comment},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name}
        ] 
      }  
      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def comment_on_attending_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_attending_activity)
#      @activity = activity
#      @commenter = commenter
#      @comment = comment
#      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'comment_on_attending_activity'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :from_name=> commenter.name,  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"COMMENTER_NAME", "content"=>commenter.name},
        {"name"=>"COMMENTER_ID", "content"=>commenter.id},
        {"name"=>"COMMENT", "content"=>comment},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
    end
  end

  def alert(user, activity, alert)
    @user = user

#    @activity = activity
#    @alert = alert
#    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
#    puts "mailing"
#    mail(to: @user.email, subject: "#{@activity.activity_name} matched one of your alerts!")
#    puts "mailed"

      # Mandrill integration

      mandrill_to = [{:email => user.email, :type => 'to'}]
      m = Mandrill::API.new
      t = 'alert'
      tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
      message = {  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_NAME", "content"=>user.name},
        {"name"=>"USER_EMAIL", "content"=>user.email},
        {"name"=>"ALERT_KEYWORDS", "content"=>alert.keywords},
        {"name"=>"ACTIVITY_ID", "content"=>activity.id},
        {"name"=>"ACTIVITY_NAME", "content"=>activity.activity_name},
        {"name"=>"ACTIVITY_DESC", "content"=>activity.description}
        ]
      }  

      sending = m.messages.send_template t, tc, message  
      logger.info sending
  end

end
