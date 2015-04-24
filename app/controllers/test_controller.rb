class TestController < ApplicationController

  def test
    PeopleFinder.new(User.where(email: 'dlogan21@gmail.com').first).find_by_being_followed
  end

end
