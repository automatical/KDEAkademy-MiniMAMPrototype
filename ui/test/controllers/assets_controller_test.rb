require 'test_helper'

class AssetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get assets_index_url
    assert_response :success
  end

  test "should get view" do
    get assets_view_url
    assert_response :success
  end

end
