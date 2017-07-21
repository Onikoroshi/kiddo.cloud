class StripeSubscriptionService

  attr_reader :account
  def initialize(account)
    @account = account
  end

  def subscribe(plan, customer_service)
    customer = customer_service.find_or_create_customer
    subscribe_customer_to_plan(customer, plan)
  end

  def subscribe_customer_to_plan(stripe_customer, plan)
    Stripe::Subscription.create(
      :customer => customer.id,
      :plan => plan,
    )
  end

end
