class StripeSubscriptionService

  attr_writer :customer_service

  attr_reader :account, :stripe_token
  def initialize(account, stripe_token)
    @account = account
    @stripe_token = stripe_token
  end

  def subscribe
    subscribe_to_enrollment_plan(customer)
  end

  def subscribe_to_enrollment_plan(stripe_customer)

    plan = Stripe::Plan.create(
      :name => "dkk_program_plan",
      :id => "#{stripe_customer.id}_#{account.center.current_program.short_code}",
      :interval => "month",
      :currency => "usd",
      :amount => price.to_i * 100
    )

    customer.subscriptions.create(
      source: stripe_token,
      plan: plan
    )

  end

  def price
    ChildEnrollment::EnrollmentPriceCalculator.new(account.children, account.center.current_program).calculate
  end

  def customer
    customer = if account.customer?
      Stripe::Customer.retrieve(account.gateway_customer_id)
    else
      Stripe::Customer.create(email: account.primary_email)
    end

    customer
  end

end
