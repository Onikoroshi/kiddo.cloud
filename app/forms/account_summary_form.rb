class AccountSummaryForm
  include ActiveModel::Model

  attr_accessor(
    :signature,
  )

  validates :signature,  presence: true

  attr_reader :center, :account
  def initialize(center, account)
    @account = account
    @center = center
    super(
      signature: signature
    )
  end

  def submit
    return unless valid?
    account.signature = signature
    account.save
  end

end

