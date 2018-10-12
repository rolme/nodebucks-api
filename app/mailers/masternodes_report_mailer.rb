class MasternodesReportMailer < ApplicationMailer
  def send_report
    @nodes = Node.all
    @nodes_down = Node.down
    mail(
      content_type: "text/html",
      subject: 'Nodebucks - Daily Masternodes Summary',
      to: (Rails.env.production?) ? 'support@nodebucks.com' : 'nodebucks.staging@gmail.com',
      bcc: ['ron.parnaso@gmail.com']
    )
  end
end
