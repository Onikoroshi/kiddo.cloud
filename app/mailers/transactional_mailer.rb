class TransactionalMailer < ApplicationMailer
  helper Account::DashboardsHelper

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end

  def welcome_summer_customer(account)
    @account = account
    mail(to: @account.primary_email, subject: "Welcome to #{account.center_name}!")
  end

  def welcome_fall_customer(account)
    @account = account
    mail(to: @account.primary_email, subject: "Welcome to #{account.center_name}!")
  end

  def waivers_and_agreements(account)
    @account = account
    file_path = "app/assets/images/Davis-Kids-Klub_Waivers-Agreements.pdf"
    attachments["waivers_and_agreements.pdf"] = File.read(file_path)
    mail(to: @account.primary_email, subject: "#{account.center_name} waivers and agreements")
  end

  def late_checkin_alert(account)
    @account = account
    mail(to: @account.primary_email, subject: "Alert about your child")
  end

  def successful_recurring_payment(account)
    @account = account
    mail(to: @account.primary_email, subject: "Recurring Payment Successful")
  end

  def failed_recurring_payment(account)
    @account = account
    mail(to: @account.primary_email, subject: "Recurring Payment Failed")
  end

  def recurring_payment_report(messages)
    @messages = messages
    mail(to: "petertcormack@gmail.com", subject: "DKK Recurring Payment Report")
  end

  def enrollment_change_report(transaction)
    @transaction = transaction
    @account = transaction.account

    mail(to: ["daviskidsklub@aol.com", "dkk.vsantos@aol.com"], subject: "DKK Enrollment Change Report")
  end
end
