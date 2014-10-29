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
    @feedback = feedback
    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")

    mail(to: "feedback@twonoo.com",
      subject: "#{@user.name} has sent you feedback.",
      template_name: "feedback")
  end

  def feedback(feedback)
    @feedback = feedback
    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")

    mail(to: "feedback@twonoo.com", subject: "Somebody has sent you feedback.")
  end

  def activity_invite(user, activity, emails)
    @user = user
    @activity = activity
    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")

    mail(bcc: emails, subject: "#{@user.name} has invited you to #{@activity.activity_name}!")
  end

  def new_follower(user, follower)
    @user = user

    if (@user.profile.notification_setting.new_follower)
      @follower = follower
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@follower.name} is now following you.")
    end
  end

  def new_message(user, sender, message)
    @user = user

    if (@user.profile.notification_setting.new_message)
      @message = message
      @sender = sender
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "You have a new message from #{@sender.name}")
    end
  end

  def new_rsvp(user, attendee, activity)
    logger.info "new_rsvp testering"
    @user = user

    if (@user.profile.notification_setting.new_rsvp)
      logger.info "new_rsvp testering receiving"
      @attendee = attendee
      @activity = activity
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@attendee.name} is joining #{@activity.activity_name}")
    end
  end

  def new_following_activity(user, organizer, activity)
    @user = user

    if (@user.profile.notification_setting.new_following_activity)
      @organizer = organizer
      @activity = activity
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@organizer.name} just created #{@activity.activity_name} on TwoNoo!")
    end
  end

  def attending_activity_update(user, activity)
    @user = user

    if (@user.profile.notification_setting.attending_activity_update)
      @activity = activity
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@activity.activity_name} has been updated on TwoNoo!")
    end
  end

  def comment_on_owned_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_owned_activity)
      @activity = activity
      @commenter = commenter
      @comment = comment
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")
    end
  end

  def comment_on_attending_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_attending_activity)
      @activity = activity
      @commenter = commenter
      @comment = comment
      attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")
    end
  end

  def alert(user, activity, alert)
    @user = user

    @activity = activity
    @alert = alert
    attachments.inline['twonoo-logo.png'] = File.read("#{Rails.root}/app/assets/images/twonoo_logo_small.png")
    puts "mailing"
    mail(to: @user.email, subject: "#{@activity.activity_name} matched one of your alerts!")
    puts "mailed"
  end

end
