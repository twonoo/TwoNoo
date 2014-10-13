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
      mail(to: @user.mail, subject: "#{@follower.name} is not following you.")
    end
  end

  def new_message(user, message)
    @user = user

    if (@user.profile.notification_setting.new_message)
    end
  end

  def new_rsvp(user, attendee)
    @user = user

    if (@user.profile.notification_setting.new_rsvp)
    end
  end

  def new_following_activity(user, organizer, activity)
    @user = user

    if (@user.profile.notification_setting.new_following_activity)
    end
  end

  def attending_activity_update(user, activity)
    @user = user

    if (@user.profile.notification_setting.attending_activity_update)
    end
  end

  def comment_on_owned_activity(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_owned_activity)
    end
  end

  def comment_on_attending_activty(user, activity, commenter, comment)
    @user = user

    if (@user.profile.notification_setting.comment_on_attending_activity)
    end
  end

  def weekly_summary(user)
    @user = user

    if (@user.profile.notification_setting.weekly_summary)
    end
  end
end
