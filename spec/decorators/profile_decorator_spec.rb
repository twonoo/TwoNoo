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
end
