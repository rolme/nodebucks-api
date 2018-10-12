class RegistrationMailer < ApplicationMailer
  def send_verify_email(user)
    @user = user
    mail(
      :content_type => "text/html",
      :subject => 'You have registered with Nodebucks.com. Please verify your email.',
      :to => @user.email
    )
  end

  def send_new_email(user)
    @user = user
    mail(
      :content_type => "text/html",
      :subject => 'You have set a new email account.',
      :to => @user.new_email
    )
  end

  def send_reset_email(user)
    @user = user
    mail(
      :content_type => "text/html",
      :subject => 'You have requested to reset your password.',
      :to => @user.email
    )
  end

  def send_login_email(user)
    @user = user
    mail(
      :content_type => "text/html",
      :subject => 'You have recently logged in.',
      :to => @user.email
    )
  end
end
