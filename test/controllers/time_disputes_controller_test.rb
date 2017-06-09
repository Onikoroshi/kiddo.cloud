require 'test_helper'

class TimeDisputesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_dispute = time_disputes(:one)
  end

  test "should get index" do
    get time_disputes_url
    assert_response :success
  end

  test "should get new" do
    get new_time_dispute_url
    assert_response :success
  end

  test "should create time_dispute" do
    assert_difference('TimeDispute.count') do
      post time_disputes_url, params: { time_dispute: { date: @time_dispute.date, email: @time_dispute.email, first_name: @time_dispute.first_name, last_name: @time_dispute.last_name, location_id: @time_dispute.location_id, message: @time_dispute.message, phone: @time_dispute.phone } }
    end

    assert_redirected_to time_dispute_url(TimeDispute.last)
  end

  test "should show time_dispute" do
    get time_dispute_url(@time_dispute)
    assert_response :success
  end

  test "should get edit" do
    get edit_time_dispute_url(@time_dispute)
    assert_response :success
  end

  test "should update time_dispute" do
    patch time_dispute_url(@time_dispute), params: { time_dispute: { date: @time_dispute.date, email: @time_dispute.email, first_name: @time_dispute.first_name, last_name: @time_dispute.last_name, location_id: @time_dispute.location_id, message: @time_dispute.message, phone: @time_dispute.phone } }
    assert_redirected_to time_dispute_url(@time_dispute)
  end

  test "should destroy time_dispute" do
    assert_difference('TimeDispute.count', -1) do
      delete time_dispute_url(@time_dispute)
    end

    assert_redirected_to time_disputes_url
  end
end
