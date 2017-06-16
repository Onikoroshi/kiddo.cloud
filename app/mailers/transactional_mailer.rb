class TransactionalMailer < ApplicationMailer

  def time_dispute_email(time_dispute)
    @time_dispute = time_dispute
    mail(to: "officepersonal@dkk.com", subject: "time dispute")
  end
end
