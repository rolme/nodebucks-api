class ReceiptMailer < ApplicationMailer
  def send_receipt(customer, cost, order)
    @customer = customer
    @cost = cost
    @order = order
    attachments.inline['email-logo'] = File.read("#{Rails.root}/app/assets/images/email-template-header-logo.png")
    mail(
      :content_type => "text/html",
      :subject => 'Thank you for purchasing.',
      :to => (Rails.env.production?) ? @customer.email : 'nodebucks.staging@gmail.com'
    )
  end
end
