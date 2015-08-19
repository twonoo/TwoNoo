require 'rails_helper'

describe ProfileController do
  describe 'GET show' do
    context 'when a profile is closed' do
      it 'redirects to the home page' do
        sign_in(create(:user))
        profile = create(:profile, :closed)
        user = create(:user, profile: profile)

        get :show, id: user.id

        expect(response).to redirect_to(root_url)
      end
    end
  end
end
