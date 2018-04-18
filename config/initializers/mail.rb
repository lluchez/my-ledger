# Guides:
# http://guides.rubyonrails.org/action_mailer_basics.html
# http://railsapps.github.io/rails-environment-variables.html

ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => 'heroku.com'
}
ActionMailer::Base.delivery_method = :smtp

#ActionMailer::Base.register_interceptor(SnapsheetMailLogger)
