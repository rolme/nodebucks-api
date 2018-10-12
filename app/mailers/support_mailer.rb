class SupportMailer < ApplicationMailer
  def send_email(subject, message)
    @subject = subject
    @message = message
    if Rails.env.production?
      mail(
        content_type: "text/html",
        subject: subject,
        to: 'support@nodebucks.com'
      )
    elsif Rails.env.staging?
      mail(
        content_type: "text/html",
        subject: subject,
        to: 'nodebucks.staging@gmail.com'
      )
    end
  end
end
