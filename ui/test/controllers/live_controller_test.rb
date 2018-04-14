require 'test_helper'

class LiveControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get live_index_url
    assert_response :success
  end

  test "should get room" do
    get live_room_url
    assert_response :success
  end

end
