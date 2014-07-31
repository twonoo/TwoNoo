require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get notifications" do
    get :notifications
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end

  test "should get followers" do
    get :followers
    assert_response :success
  end

  test "should get following" do
    get :following
    assert_response :success
  end

end
