class IdVerificationMailer < ApplicationMailer
  def send_email(user)
    @user = user
    mail(
      content_type: "text/html",
      subject: 'Nodebucks ID Verification Request',
      to: 'support@nodebucks.com',
    )
  end
end
