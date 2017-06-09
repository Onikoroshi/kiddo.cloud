require 'test_helper'

class Account::StepsControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get account_steps_controller_show_url
    assert_response :success
  end

  test "should get update" do
    get account_steps_controller_update_url
    assert_response :success
  end

end
