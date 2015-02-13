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

end