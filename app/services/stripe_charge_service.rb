class StripeChargeService

  attr_reader :account
  def initialize(account)
    @account = account
  end

  # Receives Stripe::Charge object on success
  # Raises exception on unsuccessful charge
  def charge
    charge = Stripe::Charge.create(
      amount: 1000,
      currency: "usd",
      description: "Example charge",
      customer: account.gateway_customer_id
    )
  end

end
