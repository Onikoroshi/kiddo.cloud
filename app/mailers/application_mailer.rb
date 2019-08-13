class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@manage.daviskidsklub.com', sender: 'office@daviskidsklub.com', reply_to: 'office@daviskidsklub.com'
  layout 'mailer'
end
