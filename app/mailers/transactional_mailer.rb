class TransactionalMailer < ApplicationMailer
  helper Account::DashboardsHelper

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end

  def welcome_summer_customer(account)
    @account = account

    file_path = "app/assets/images/Walking Policy.pdf"
    attachments["walking_policy.pdf"] = File.read(file_path)

    file_path = "app/assets/images/DKK Chromebook policy.pdf"
    attachments["chromebook_policy.docx"] = File.read(file_path)

    file_path = "app/assets/images/Spanish Application 2018-09.pdf"
    attachments["spanish_application.pdf"] = File.read(file_path)

    file_path = "app/assets/images/English Application 2018-09.pdf"
    attachments["english_application.pdf"] = File.read(file_path)

    file_path = "app/assets/images/Behavior Agreement.pdf"
    attachments["behavior_agreement.pdf"] = File.read(file_path)

    file_path = "app/assets/images/Welcome Summer Camp 2019.pdf"
    attachments["welcome_packet.pdf"] = File.read(file_path)

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
    mail(to: @account.all_emails, subject: "Your DKK Payment Information is incomplete or out-of-date")
  end

  def recurring_payment_report(messages)
    @messages = messages
    mail(to: [ "petertcormack@gmail.com", "office@daviskidsklub.com", "admin@daviskidsklub.com" ], subject: "DKK Recurring Payment Report")
  end

  def one_time_unpaid_payment_report(messages)
    @messages = messages
    mail(to: [ "petertcormack@gmail.com", "office@daviskidsklub.com", "admin@daviskidsklub.com" ], subject: "DKK One-Time unpaid Payment Report")
  end

  def enrollment_change_report(transactions)
    @transactions = transactions
    @account = transactions.first.account

    mail(to: ["office@daviskidsklub.com", "admin@daviskidsklub.com"], subject: "DKK Enrollment Change Report")
  end

  def late_notifications_report(children_notified = [])
    ap "blank? #{children_notified.blank?}"
    # return if children_notified.blank?

    @children_notified = children_notified

    mail(to: ["petertcormack@gmail.com", "office@daviskidsklub.com", "admin@daviskidsklub.com"], subject: "Tardy Notifications Report")
  end

  def exception_notification(except_message, except_backtrace)
    @exception_message = except_message
    @exception_backtrace = except_backtrace

    mail(to: "petertcormack@gmail.com", subject: "Exception Notification")
  end
end
