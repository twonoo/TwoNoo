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

    interests_array = []
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
        matching_interests.each do |interest|
          interest_string = interest.name
          if interest.interests_option_value(user.id).present?
            interest_string << " (#{interest.interests_option_value(user.id)})"
          end
          interests_array << interest_string
        end
        "Matching Interests: #{interests_array[0,max].join(', ')}"
      else
        'Matching Interests: None'
      end
    else
      'Matching Interests: None'
    end

  end

end