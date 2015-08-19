require 'pry'
require 'rails_helper'

feature 'Users closes their account' do
  xscenario 'and gives a reason for doing so', js: true do
    user = sign_in_user

    visit profile_edit_path
    click_on 'Close my account'

    choose('I have multiple accounts')
    click_on 'Close Account'

    expect(user.profile).to be_closed
  end

  def sign_in_user(user = create(:user))
    visit new_user_session_path

    within '#new_user' do
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: 'password'
      click_on 'Sign in'
    end

    user
  end
end
