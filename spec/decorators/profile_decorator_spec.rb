require 'rails_helper'

describe ProfileDecorator do
  describe '#display_name' do
    it 'displays the full first name and last initial' do
      profile = create(:profile, first_name: 'Steve', last_name: 'Keefe')

      decorated_profile = ProfileDecorator.new(profile)

      expect(decorated_profile.display_name).to eq('Steve K')
    end

    it 'capitalizes the name and last initial' do
      profile = create(:profile, first_name: 'sTeVe', last_name: 'kEEFe')

      decorated_profile = ProfileDecorator.new(profile)

      expect(decorated_profile.display_name).to eq('Steve K')
    end
  end

  describe '#initials' do
    it 'displays the initials of the first and last name' do
      profile = create(:profile, first_name: 'Steve', last_name: 'Keefe')

      decorated_profile = ProfileDecorator.new(profile)

      expect(decorated_profile.initials).to eq('SK')
    end
  end

  describe '#last_initial' do
    it 'displays first character of the last name' do
      profile = create(:profile, first_name: 'Steve', last_name: 'Keefe')

      decorated_profile = ProfileDecorator.new(profile)

      expect(decorated_profile.last_initial).to eq('K')
    end
  end
end
