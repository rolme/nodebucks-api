class ContactsController < ApplicationController
  before_action :authenticate_admin_request, only: [:update]

  def index
    @contacts = Contact.unreviewed.order(created_at: :asc)
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      render json: { status: :ok, message: 'Email is successfully sent to support team.' }
    else
      render json: { status: :error, messages: @contact.errors.full_messages.join(', ') }
    end
  end

  def reviewed
    @contact = Contact.find(params[:contact_id])
    if @contact.update_attributes(reviewed_by_user: User.find_by(slug: params[:user_slug]).id, reviewed_at: Time.zone.now)
      render json: { status: :ok, message: 'Contact is reviewed successfully.' }
    else
      render json: { status: :error, messages: @contact.errors.full_messages.join(', ') }
    end
  end

  protected

  def contact_params
    params.require(:contact).permit(
      :subject,
      :email,
      :message
    )
  end
end
