class TransactionalMailer < ApplicationMailer

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end

  def welcome_customer(center, customer)
    @center = center
    @customer = customer
    mail(to: customer.email, subject: "Welcome to #{center.name}!")
  end
end
