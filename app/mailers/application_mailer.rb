class ApplicationMailer < ActionMailer::Base
  default from: 'info@manage.daviskidsklub.com'
  default sender: 'daviskidsklub@aol.com'
  layout 'mailer'
end
