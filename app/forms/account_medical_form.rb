class AccountMedicalForm
  include ActiveModel::Model

  attr_accessor(
    :family_physician,
    :physician_phone,
    :family_dentist,
    :dentist_phone,
    :insurance_company,
    :insurance_policy_number,
    :medical_waiver_agreement,
    :step
  )

  validates :medical_waiver_agreement,  acceptance: true

  attr_reader :center, :account
  def initialize(center, account)
    @account = account
    @center = center

    super(
      family_physician: account.family_physician,
      physician_phone: account.physician_phone,
      family_dentist: account.family_dentist,
      dentist_phone: account.dentist_phone,
      insurance_company: account.insurance_company,
      insurance_policy_number: account.insurance_policy_number,
      medical_waiver_agreement: account.medical_waiver_agreement
    )
  end

  def submit
    return unless valid?
    account.assign_attributes(
      family_physician: family_physician,
      physician_phone: physician_phone,
      family_dentist: family_dentist,
      dentist_phone: dentist_phone,
      insurance_company: insurance_company,
      insurance_policy_number: insurance_policy_number,
      medical_waiver_agreement: medical_waiver_agreement
    )
    account.save
  end

end