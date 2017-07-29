class StripeCustomerService

  attr_reader :account
  def initialize(account)
    @account = account
  end

  def find_or_create_customer
    customer = if account.customer?
      Stripe::Customer.retrieve(account.gateway_customer_id)
    else
      Stripe::Customer.create(email: account.primary_email)
    end
  end

  def find_customer
    Stripe::Customer.retrieve(account.gateway_customer_id)
  end

end