require 'test_helper'

class Account::ChildrenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_child = account_children(:one)
  end

  test "should get index" do
    get account_children_url
    assert_response :success
  end

  test "should get new" do
    get new_account_child_url
    assert_response :success
  end

  test "should create account_child" do
    assert_difference('Account::Child.count') do
      post account_children_url, params: { account_child: {  } }
    end

    assert_redirected_to account_child_url(Account::Child.last)
  end

  test "should show account_child" do
    get account_child_url(@account_child)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_child_url(@account_child)
    assert_response :success
  end

  test "should update account_child" do
    patch account_child_url(@account_child), params: { account_child: {  } }
    assert_redirected_to account_child_url(@account_child)
  end

  test "should destroy account_child" do
    assert_difference('Account::Child.count', -1) do
      delete account_child_url(@account_child)
    end

    assert_redirected_to account_children_url
  end
end
