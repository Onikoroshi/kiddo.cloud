require 'test_helper'

class Account::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_dashboard = account_dashboards(:one)
  end

  test "should get index" do
    get account_dashboards_url
    assert_response :success
  end

  test "should get new" do
    get new_account_dashboard_url
    assert_response :success
  end

  test "should create account_dashboard" do
    assert_difference('Account::Dashboard.count') do
      post account_dashboards_url, params: { account_dashboard: {  } }
    end

    assert_redirected_to account_dashboard_url(Account::Dashboard.last)
  end

  test "should show account_dashboard" do
    get account_dashboard_url(@account_dashboard)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_dashboard_url(@account_dashboard)
    assert_response :success
  end

  test "should update account_dashboard" do
    patch account_dashboard_url(@account_dashboard), params: { account_dashboard: {  } }
    assert_redirected_to account_dashboard_url(@account_dashboard)
  end

  test "should destroy account_dashboard" do
    assert_difference('Account::Dashboard.count', -1) do
      delete account_dashboard_url(@account_dashboard)
    end

    assert_redirected_to account_dashboards_url
  end
end
