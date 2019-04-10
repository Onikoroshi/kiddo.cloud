class StripeCustomerService
  attr_reader :account
  def initialize(account)
    @account = account
  end

  def find_or_create_customer(token)
    customer = nil
    if account.customer?
      customer = Stripe::Customer.retrieve(account.gateway_customer_id)
    else
      customer = Stripe::Customer.create(email: account.primary_email, source: token)
      account.update_attributes(gateway_customer_id: customer.id, card_brand: customer.sources.data[0].brand, card_last4: customer.sources.data[0].last4)
    end
    ap customer
    customer
  end

  def find_customer
    account.gateway_customer_id.present? ? Stripe::Customer.retrieve(account.gateway_customer_id) : nil
  end
end
