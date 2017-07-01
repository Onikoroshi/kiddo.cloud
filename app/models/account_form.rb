class AccountForm
  include ActiveModel::Model

  delegate :parent_first_name, :parent_last_name, :email, :password, to: :user

  attr_accessor(
    :current_user,
    :parents,
    :contacts,
    :step
  )

  def contacts_attributes=(attributes)
    @contacts ||= []
    attributes.each do |i, contact_params|
      @contacts.push(EmergencyContact.new(contact_params))
    end
  end

  def parents_attributes=(attributes)
    @parents ||= []
    attributes.each do |i, parent_params|
      @parents.push(Parent.new(parent_params))
    end
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
    parents_attributes(params)
    account.save
  end

  def account
    @account ||= Account.new(
      parents: parents,
      emergency_contacts: contacts
    )
  end

end

