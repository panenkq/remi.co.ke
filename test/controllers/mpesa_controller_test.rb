require "test_helper"

class MpesaControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get mpesa_callback_url
    assert_response :success
  end
end
