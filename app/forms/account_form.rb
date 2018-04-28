class AccountForm
  include ActiveModel::Model

  attr_accessor(
    :parent_first_name,
    :parent_last_name,
    :parent_phone,
    :parent_street,
    :parent_extended,
    :parent_locality,
    :parent_region,
    :parent_postal_code,

    :parent_guardian_first_name,
    :parent_guardian_last_name,
    :parent_guardian_phone,
    :parent_guardian_street,
    :parent_guardian_extended,
    :parent_guardian_locality,
    :parent_guardian_region,
    :parent_guardian_postal_code,

    :emergency_contact_first_name,
    :emergency_contact_last_name,
    :emergency_contact_phone,

    :waiver_agreement,
    :step
  )

  validates :parent_first_name,  presence: true
  validates :parent_last_name,   presence: true
  validates :parent_phone,       presence: true
  validates :parent_street,      presence: true
  validates :parent_locality,    presence: true
  validates :parent_region,      presence: true
  validates :parent_postal_code, presence: true

  validates :emergency_contact_first_name, presence: true
  validates :emergency_contact_last_name,  presence: true
  validates :emergency_contact_phone,      presence: true

  validates :waiver_agreement, acceptance: true

  attr_reader :center, :account, :current_user
  def initialize(center:, account:, current_user:)
    @account = account
    @center = center
    @current_user = current_user
    account.center = center
    super(all_attributes)
  end

  def submit
    return unless valid?

    save_parent
    save_second_parent
    save_emergency_contact
    sign_waivers

    account.save!
  end

  private

  def sign_waivers
    account.waiver_agreement = waiver_agreement.present? && waiver_agreement == "1"
  end

  def save_parent
    parent.update_attributes(
      first_name: parent_first_name,
      last_name: parent_last_name,
      phone: parent_phone,
      primary: true,
      user_id: current_user.id
    )

    parent.address.update_attributes(
      street: parent_street,
      extended: parent_extended,
      locality: parent_locality,
      region: parent_region,
      postal_code: parent_postal_code
    )
  end

  def save_second_parent
    parent_guardian.update_attributes(
      first_name: parent_guardian_first_name,
      last_name: parent_guardian_last_name,
      phone: parent_guardian_phone,
      primary: false
    )

    parent_guardian.address.update_attributes(
      street: parent_guardian_street,
      extended: parent_guardian_extended,
      locality: parent_guardian_locality,
      region: parent_guardian_region,
      postal_code: parent_guardian_postal_code
    )

    account.parents << parent_guardian
  end

  def save_emergency_contact
    emergency_contact.update_attributes(
      first_name: emergency_contact_first_name,
      last_name: emergency_contact_last_name,
      phone: emergency_contact_phone
    )
    account.emergency_contacts << emergency_contact
  end

  def parent_attributes_hash
    {
      parent_first_name: parent.first_name,
      parent_last_name: parent.last_name,
      parent_phone: parent.phone,
      parent_street: parent.address.street,
      parent_extended: parent.address.extended,
      parent_locality: parent.address.locality,
      parent_region: parent.address.region,
      parent_postal_code: parent.address.postal_code
    }
  end

  def parent_guardian_attributes_hash
    {
      parent_guardian_first_name: parent_guardian.first_name,
      parent_guardian_last_name: parent_guardian.last_name,
      parent_guardian_phone: parent_guardian.phone,
      parent_guardian_street: parent_guardian.address.street,
      parent_guardian_extended: parent_guardian.address.extended,
      parent_guardian_locality: parent_guardian.address.locality,
      parent_guardian_region: parent_guardian.address.region,
      parent_guardian_postal_code: parent_guardian.address.postal_code
    }
  end

  def emergency_contact_hash
    {
      emergency_contact_first_name: emergency_contact.first_name,
      emergency_contact_last_name: emergency_contact.last_name,
      emergency_contact_phone: emergency_contact.phone
    }
  end

  def all_attributes
    parent_attributes_hash.merge(emergency_contact_hash).merge(parent_guardian_attributes_hash)
  end

  def parent
    parent ||= account.primary_parent
    parent.address ||= parent.build_address
    parent
  end

  def parent_guardian
    guardian = account.secondary_parent || account.build_secondary_parent
    guardian.address || guardian.build_address
    guardian
  end

  def emergency_contact
    account.emergency_contacts.first || account.emergency_contacts.build
  end

end
