require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get main_top_url
    assert_response :success
  end

  test "should get login" do
    get main_login_url
    assert_response :success
  end

  test "should get registration" do
    get main_registration_url
    assert_response :success
  end

  test "should get account" do
    get main_account_url
    assert_response :success
  end

  test "should get account_info" do
    get main_account_info_url
    assert_response :success
  end

end
