class TransactionalMailer < ApplicationMailer
  helper Account::DashboardsHelper

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end

  def welcome_summer_customer(account)
    @account = account

    file_path = "app/assets/images/Summer Camp daily schedule.docx"
    attachments["daily_schedule.docx"] = File.read(file_path)

    file_path = "app/assets/images/DKK Chromebook policy.pdf"
    attachments["chromebook_policy.docx"] = File.read(file_path)

    file_path = "app/assets/images/Class Visit Letter -Davis-1.docx"
    attachments["class_visit_letter.docx"] = File.read(file_path)

    file_path = "app/assets/images/English & Spanish Application 07-2017-1.pdf"
    attachments["english_spanish_application.pdf"] = File.read(file_path)

    mail(to: @account.all_emails, subject: "Welcome to #{account.center_name}!")
  end

  def welcome_fall_customer(account)
    @account = account
    mail(to: @account.all_emails, subject: "Welcome to #{account.center_name}!")
  end

  def waivers_and_agreements(account)
    @account = account
    file_path = "public/Davis-Kids-Klub_Waivers-Agreements.pdf"
    attachments["waivers_and_agreements.pdf"] = File.read(file_path)
    mail(to: @account.all_emails, subject: "#{account.center_name} waivers and agreements")
  end

  def late_checkin_alert(account, child)
    @account = account
    @child = child
    mail(to: @account.all_emails, subject: "Alert about your child")
  end

  def successful_recurring_payment(account)
    @account = account
    mail(to: @account.all_emails, subject: "Recurring Payment Successful")
  end

  def failed_recurring_payment(account)
    @account = account
    mail(to: @account.all_emails, subject: "Recurring Payment Failed")
  end

  def recurring_payment_report(messages)
    @messages = messages
    mail(to: "petertcormack@gmail.com", subject: "DKK Recurring Payment Report")
  end

  def enrollment_change_report(transaction)
    @transaction = transaction
    @account = transaction.account

    mail(to: ["daviskidsklub@aol.com", "dkk.vsantos@aol.com", "aryn.yancher@gmail.com"], subject: "DKK Enrollment Change Report")
  end

  def late_notifications_report(children_notified = [])
    ap "blank? #{children_notified.blank?}"
    return if children_notified.blank?

    @children_notified = children_notified

    mail(to: ["petertcormack@gmail.com", "daviskidsklub@aol.com", "dkk.vsantos@aol.com", "aryn.yancher@gmail.com"], subject: "Tardy Notifications Report")
  end
end
