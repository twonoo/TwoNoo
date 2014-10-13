class UserMailer < ActionMailer::Base
  default from: "no-reply@twonoo.com"

  def welcome_email(user)
    @user = user
    @url  = root_url
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def activity_invite(user, activity, emails)
    @user = user
    @activity = activity

    mail(bcc: emails, subject: "#{@user.name} has invited you to #{@activity.activity_name}!")
  end

  def new_follower(user, follower)
    @user = user

    if (@user.profile.notification_setting.new_follower)
      @follower = follower
      mail(to: @user.email, subject: "#{@follower.name} is now following you.")
    end
  end

  def new_message(user, sender, message)
    @user = user

    if (@user.profile.notification_setting.new_message)
      @message = message
      @sender = sender
      mail(to: @user.email, subject: "You have a new message from #{@sender.name}")
    end
  end

  def new_rsvp(user, attendee, activity)
    @user = user

    if (@user.profile.notification_setting.new_rsvp)
      @attendee = attendee
      @activity = activity
      mail(to: @user.email, subject: "#{@attendee.name} is joining #{@activity.activity_name}")
    end
  end

  def new_following_activity(user, organizer, activity)
    @user = user

    if (@user.profile.notification_setting.new_following_activity)
      @organizer = organizer
      @activity = activity
      mail(to: @user.email, subject: "#{@organizer.name} just created #{@activity.activity_name} on TwoNoo!")
    end
  end

  def attending_activity_update(user, activity)
    @user = user

    if (@user.profile.notification_setting.attending_activity_update)
      @activity = activity
      mail(to: @user.email, subject: "#{@activity.activity_name} has been updated on TwoNoo!")
    end
  end

  def comment_on_owned_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_owned_activity)
      @activity = activity
      @commenter = commenter
      @coment = comment
      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")
    end
  end

  def comment_on_attending_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_attending_activity)
      @activity = activity
      @commenter = commenter
      @comment = comment
      mail(to: @user.email, subject: "#{@commenter.name} posted a new comment on #{@activity.activity_name}")
    end
  end

end
