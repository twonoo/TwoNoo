require 'pry'
require 'rails_helper'
require 'spec_helper'

feature 'User searches for activities', js: true do
  stub_geocode_with(city: 'Boston', state: 'MA', latitude: 42.3601, longitude: -71.0589)
  stub_timezone_with("Mountain Time (US & Canada)")
  context 'User is not logged in' do
    # Behavior should still occur when the user hasn't logged in.
    context 'selecting all interests' do
      scenario "there are no matching activities" do
        # When no activities match, we should see a message to that effect.
        visit root_path
        execute_script("$('#terms').click()") # Inputs triggering modals are not super testable
        click_on "All"
        click_on "DONE"
        click_on "GO!"
        sleep 1

        expect(current_path).to have_content("/search")
        expect(page).to have_content("No activities matched")
      end

      scenario "there are matching activities" do
        # When an activity matches, we should not see that message.  In addition, that activity
        # should show up in the activities list.
        activity = FactoryGirl.create(:activity, activity_name: "The Best Activity")

        visit root_path
        execute_script("$('#terms').click()")
        click_on "All"
        click_on "DONE"
        click_on "GO!"
        sleep 1
        
        expect(current_path).to have_content("/search")
        expect(page).not_to have_content("No activities matched")
        expect(page).to have_content("The Best Activity")
      end
    end
  end

  context "User is logged in" do
    let(:user) { sign_in_user }

    before :each do
    end

    context 'selecting all interests' do
      scenario "there are no matching activities" do
        # When no activities match, we should see a message to that effect.
        visit root_path
        execute_script("$('#terms').click()")
        click_on "All"
        click_on "DONE"
        click_on "GO!"
        sleep 1

        expect(current_path).to have_content("/search")
        expect(page).to have_content("No activities matched")
      end

      scenario "there are matching activities" do
        # When an activity matches, we should not see that message.  In addition, that activity
        # should show up in the activities list.
        activity = FactoryGirl.create(:activity, activity_name: "The Best Activity")

        visit root_path
        execute_script("$('#terms').click()")
        click_on "All"
        click_on "DONE"
        click_on "GO!"
        sleep 1

        expect(current_path).to have_content("/search")
        expect(page).not_to have_content("No activities matched")
        expect(page).to have_content("The Best Activity")
      end
    end

    context "selecting some interests" do
      let(:interest_1) { FactoryGirl.create(:interest, name: "My Interest Number 1") }
      let(:interest_2) { FactoryGirl.create(:interest, name: "My Interest Number 2") }
      let!(:activity_1) do 
        activity = FactoryGirl.build(:activity, activity_name: "Activity Interest 1")
        activity.interests << interest_1
        activity.save!
      end
      let!(:activity_2) do 
        activity = FactoryGirl.build(:activity, activity_name: "Activity Interest 2")
        activity.interests << interest_2
        activity.save!
      end

      scenario "one matching activity, one not matching activity" do
        visit root_path
        execute_script("$('#terms').click()")
        click_on 'My Interest Number 1'
        click_on "DONE"
        click_on "GO!"
        sleep 1

        expect(current_path).to have_content("/search")
        expect(page).not_to have_content("No activities matched")
        expect(page).to have_content("Activity Interest 1")
        expect(page).not_to have_content("Activity Interest 2")
      end

      scenario "no matching activities" do
        other_interest = FactoryGirl.create(:interest, name: "My Other Interest")
        
        visit root_path
        execute_script("$('#terms').click()")
        click_on "My Other Interest"
        click_on "DONE"
        click_on "GO!"
        sleep 1

        expect(current_path).to have_content("/search")
        # We expect it to show them activities out of the interest they asked about
        expect(page).to have_content("No activities matched")
        expect(page).to have_content("Activity Interest 1")
        expect(page).to have_content("Activity Interest 2")
      end
    end
  end

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
