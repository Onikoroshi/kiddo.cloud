class TransactionalMailer < ApplicationMailer

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end

  def welcome_customer(account)
    @account = account
    mail(to: @account.primary_email, subject: "Welcome to #{account.center_name}!")
  end

  def waivers_and_agreements(account)
    @account = account
    attachments['waivers_and_agreements.pdf'] = File.read("app/assets/images/Davis-Kids-Klub_Waivers-Agreements.pdf")
    mail(to: @account.primary_email, subject: "#{account.center_name} waivers and agreements")
  end
end
