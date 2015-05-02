class PeopleFinder

  @@finders = %w(facebook_friends shared_interest_options shared_interests shared_following being_followed)

  def initialize(user, options={})

    @user = user
    @other_users = User.unscoped.all
    @options = options
    @options.merge!(same_state: true) if @options[:same_state].nil?
    @options.merge!(min_shared_following: 4) if @options[:min_shared_following].nil?
    @options.merge!(interests_filter: %w(Tennis Running)) if @options[:interests_filter].nil?
    @options.merge!(verbose: false) if @options[:verbose].nil?

  end

  def inspect
    log ''
    log 'Initialized with:'
    log @options.inspect
    log "user email: #{@user.email} - #{@user.id}"
    log "found #{@other_users.count} users to compare against"
  end

  def find_by_all
    @@finders.each do |finder|
      send("find_by_#{finder}")
    end
  end

  def find_by_facebook_friends
    toggle_ar_logger

    log '**** Running find_by_facebook_friends ****'
    @other_users.each do |other_user|
      if should_pursue_user?(other_user)
        if other_user.facebook_friends?(@user)
          create_recommended_follower_record(other_user, 1, "You're facebook friends")
        else
          log 'Not friends'
        end
      end
    end

    toggle_ar_logger
  end

  def find_by_shared_following
    toggle_ar_logger

    log '**** Running find_by_shared_following ****'
    @other_users.each do |other_user|
      if should_pursue_user?(other_user) && users_shares_state(other_user)
        if shares_enough_following(other_user)
          create_recommended_follower_record(other_user, 2, "You're following 4+ of the same people")
        end
      end
    end

    toggle_ar_logger
  end

  def find_by_shared_interests
    toggle_ar_logger

    log '**** Running find_by_shared_interests ****'
    @other_users.each do |other_user|
      if should_pursue_user?(other_user) && users_shares_state(other_user)
        interests = get_shared_interests(other_user)
        if interests && interests.length >= 5
          create_recommended_follower_record(other_user, 5, 'You have 5+ shared interests', "#{shared_interest_option.interest.name} (#{shared_interest_option.option_value})")
        end
      end
    end

    toggle_ar_logger
  end

  def find_by_being_followed
    toggle_ar_logger

    log '**** Running find_by_being_followed ****'
    @other_users.each do |other_user|
      if should_pursue_user?(other_user) && users_shares_state(other_user)
        if is_being_followed(other_user)
          create_recommended_follower_record(other_user, 3, "They're following you")
        end
      end
    end

    toggle_ar_logger
  end

  def find_by_shared_interest_options
    toggle_ar_logger

    log '**** Running find_by_shared_interest_options ****'
    @other_users.each do |other_user|
      if should_pursue_user?(other_user) && users_shares_state(other_user)
        shared_interest_option = get_shared_interest_option(other_user)
        if shared_interest_option.present?
          create_recommended_follower_record(other_user, 4, "You're at the same level", "#{shared_interest_option.interest.name} (#{shared_interest_option.option_value})")
        end
      end
    end

    toggle_ar_logger
  end

  private

  def should_pursue_user?(other_user)
    log(' ')
    log "Checking #{@user.email}(#{@user.id}) against #{other_user.email}(#{other_user.id})"
    if !follow_relationship_exists?(other_user) && !rec_follow_relationship_exists?(other_user) && other_user.id != @user.id
      log 'Pursuing'; return true
    else
      log 'Not pursuing (relationship already exists or users are the same)'; return false
    end
  end

  def users_shares_state(other_user)
    log 'Ignoring state' and return true if @options[:same_state] == false
    if @user.profile.state == other_user.profile.state
      log 'Same state'; return true
    else
      log "Different states, #{@user.profile.state} / #{other_user.profile.state}"; return false
    end
  end

  def shares_enough_following(other_user)
    if num_same_people_followed(other_user) == @options[:min_shared_following]
      log "Follows at lease #{@options[:min_shared_following]} of the same people"; return true
    else
      log "Does not follow #{@options[:min_shared_following]} or more of the same people"; return false
    end
  end

  def num_same_people_followed(other_user)
    user_is_following = @user.follow_relationships.pluck(:followed_id)
    other_user_is_following = other_user.follow_relationships.pluck(:followed_id)
    shared_following = (user_is_following & other_user_is_following).length
    log "Both parties follow #{shared_following} of the same people"; return shared_following
  end

  def is_being_followed(other_user)
    if @user.followers.where(id: other_user.id).exists?
      log 'User is being followed'; return true
    else
      log 'User is not being followed'; return false
    end
  end

  def get_shared_interests(other_user)
    (@user.interests.pluck(:name) || []) & (other_user.interests.pluck(:name) || [])
  end

  def get_shared_interest_option(other_user)
    shared_interests = get_shared_interests(other_user)
    log "Shared interests before filter #{shared_interests}"
    shared_interests = shared_interests.delete_if { |i| !@options[:interests_filter].include? i }
    log "Shared interests after filter #{shared_interests}"
    if shared_interests.length > 0
      log 'At least 1 shared interest after filter'
      shared_interests.each do |interest|
        interest = Interest.where(name: interest).first
        if interest.interests_option_id(@user.id) == interest.interests_option_id(other_user.id)
          shared_interest_option = InterestsOption.find_by_id(interest.interests_option_id(@user.id))
          if shared_interest_option
            log "Found shared interest option #{shared_interest_option.option_name} - #{shared_interest_option.option_value}"
            return shared_interest_option
          else
            log 'An interest was found, but it did not contain an option'
          end
        end
      end
    else
      log 'No shared interests after filter'
    end

    log 'No shared interests after filter'; return nil
  end

  def follow_relationship_exists?(other_user)
    FollowRelationship.exists?(follower_id: @user.id, followed_id: other_user.id)
  end

  def rec_follow_relationship_exists?(other_user)
    RecommendedFollower.exists?(user_id: @user.id, recommended_follower_id: other_user.id)
  end

  def create_recommended_follower_record(other_user, order, match_criteria, match_data=nil)
    log '>>>>> Creating new recommended_follower record'
    recommended_follower_record = @user.recommend_follow!(other_user, order, match_criteria, match_data)
    if recommended_follower_record && recommended_follower_record.persisted?
      log "Created record #{recommended_follower_record.id}"
    else
      log "Record returned: #{recommended_follower_record.nil? ? 'nil' : recommended_follower_record.errors.full_messages}"
    end
  end

  def toggle_ar_logger
    if @options[:verbose]
      if ActiveRecord::Base.logger.present?
        @ar_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
      else
        ActiveRecord::Base.logger = @ar_logger
      end
    end
  end

  def log(message)
    if @options[:verbose]
      puts message
    end
  end

end