class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@manage.daviskidsklub.com', sender: 'daviskidsklub@aol.com', reply_to: 'daviskidsklub@aol.com'
  layout 'mailer'
end
