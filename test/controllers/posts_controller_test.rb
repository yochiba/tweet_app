require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get feed" do
    get posts_feed_url
    assert_response :success
  end

  test "should get upload" do
    get posts_upload_url
    assert_response :success
  end

  test "should get edit" do
    get posts_edit_url
    assert_response :success
  end

  test "should get delete" do
    get posts_delete_url
    assert_response :success
  end

end
