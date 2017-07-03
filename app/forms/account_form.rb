class AccountForm
  include ActiveModel::Model

  delegate :parent_first_name, :parent_last_name, :email, :password, to: :current_user

  attr_accessor(
    :parent_first_name,
    :parent_last_name,
    :parent_phone,
    :parent_street,
    :parent_extended,
    :parent_locality,
    :parent_region,
    :parent_postal_code,
    :step
  )

  validates :parent_first_name,  presence: true

  attr_reader :center, :account, :current_user
  def initialize(center, account, current_user)
    @account = account
    @center = center
    @current_user = current_user
    super(parent_attributes_hash)
  end

  def submit
    return unless valid?

    current_user.update_attributes(
      first_name: parent_first_name,
      last_name: parent_last_name,
    )

    parent.address.assign_attributes(
      street: parent_street,
      extended: parent_extended,
      locality: parent_locality,
      region: parent_region,
      postal_code: parent_postal_code
    )
    parent.phone = parent_phone
    parent.primary = true
    parent.user_id = current_user.id
    parent.save!

    account.parents << parent
    account.center = center
    account.save!
  end

  private

  def parent_attributes_hash
    {
      parent_first_name: current_user.first_name,
      parent_last_name: current_user.last_name,
      parent_phone: parent.phone,
      parent_street: parent.address.street,
      parent_extended: parent.address.extended,
      parent_locality: parent.address.locality,
      parent_region: parent.address.region,
      parent_postal_code: parent.address.postal_code
    }
  end

  def parent
    parent = account.parents.first || account.parents.build
    parent.address = parent.address || parent.build_address
    parent
  end

end

