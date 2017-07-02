require 'test_helper'

class Children::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @children_registration = children_registrations(:one)
  end

  test "should get index" do
    get children_registrations_url
    assert_response :success
  end

  test "should get new" do
    get new_children_registration_url
    assert_response :success
  end

  test "should create children_registration" do
    assert_difference('Children::Registration.count') do
      post children_registrations_url, params: { children_registration: {  } }
    end

    assert_redirected_to children_registration_url(Children::Registration.last)
  end

  test "should show children_registration" do
    get children_registration_url(@children_registration)
    assert_response :success
  end

  test "should get edit" do
    get edit_children_registration_url(@children_registration)
    assert_response :success
  end

  test "should update children_registration" do
    patch children_registration_url(@children_registration), params: { children_registration: {  } }
    assert_redirected_to children_registration_url(@children_registration)
  end

  test "should destroy children_registration" do
    assert_difference('Children::Registration.count', -1) do
      delete children_registration_url(@children_registration)
    end

    assert_redirected_to children_registrations_url
  end
end
