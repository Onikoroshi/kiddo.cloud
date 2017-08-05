class StripeSubscriptionService

  attr_writer :customer_service

  attr_reader :account, :stripe_token, :program
  def initialize(account, stripe_token)
    @account = account
    @stripe_token = stripe_token
    @program = account.center.current_program
  end

  def subscribe
    subscribe_to_custom_plan(customer)
  end

  # Unless we create multiple subscriptions per customer,
  # we can't subscribe to preset plans like "Davis Kids Klub Fall 2017 Daily drop-in per day (M,T,TH,F)".
  #
  # We have multiple children, so we have to generate a custom amount / plan per account
  # and create a new plan for the family. We then subscribe the account to the new plan
  def subscribe_to_custom_plan(stripe_customer)

    plan = Stripe::Plan.create(
      :name => "#{program.name} custom plan",
      :id => "#{stripe_customer.id}_#{program.short_code}",
      :interval => "month",
      :currency => "usd",
      :amount => price.to_i * 100
    )

    customer.subscriptions.create(
      source: stripe_token,
      plan: plan,
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
