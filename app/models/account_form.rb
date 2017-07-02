class AccountForm
  include ActiveModel::Model

  delegate :parent_first_name, :parent_last_name, :email, :password, to: :user

  attr_accessor(
    :current_user,
    :parents,
    :contacts,
    :step
  )

  attr_reader :account
  def initialize(account)
    @account = account
  end

  def user
    @user || User.new
  end

  def parents
    @parents ||= [
      Parent.new(user: @current_user)
    ]
  end

  def contacts
    @contacts ||= [
      EmergencyContact.new
    ]
  end

  def submit
    return unless valid?
    account.save
  end

  def account
    @account ||= Account.new
  end

end

