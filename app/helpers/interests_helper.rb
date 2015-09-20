module InterestsHelper

  def interests_tag(user)

    interests_array = []

    if user && user.interests.present?
      user.interests.order(:name).all.each do |interest|
        interest_string = interest.name
        if interest.interests_option_value(user.id).present?
          interest_string << " (#{interest.interests_option_value(user.id)})"
        end
        interests_array << interest_string
      end
      interests_array.join(', ')
    else
      ''
    end

  end

  def matching_interests_tag(user, other_user, max=20)

    user_interests = user.present? ? user.interests.order(:name) : []
    other_user_interests = other_user.present? ? other_user.interests.order(:name) : []
    matching_interests = []

    if user_interests.length > 0 && other_user_interests.length > 0
      user_interests.each do |interest|
        matching_interest = other_user_interests.select { |x| x.id == interest.id }
        if matching_interest.present?
          matching_interests << matching_interest.first
        end
      end

      if matching_interests.length > 0
        matching_interests_to_string(matching_interests, user, max)
      else
        'Matching Interests: None'
      end
    elsif user.nil?
      # No user logged in, so we show all user interests
      matching_interests_to_string(other_user_interests, nil)
    else
      'Matching Interests: None'
    end
  end

  def matching_interests_to_string(interests, user, max=20)
    int_strings = interests.map{|x| human_readable_interest_str(x, user)}
    if user.nil?
      "Interests: #{int_strings[0,max].join(', ')}#{'...' if interests.count > max}"
    else
      "Matching Interests: #{int_strings[0,max].join(', ')}#{'...' if interests.count > max}"
    end
  end

  def human_readable_interest_str(interest, user)
    if user && interest.interests_option_value(user.id).present?
      "#{interest.name} (#{interest.interests_option_value(user.id)})"
    else
      interest.name
    end
  end

end