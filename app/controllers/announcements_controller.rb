class AnnouncementsController < ApplicationController
  before_action :authenticate_admin_request, only: [:create]

  def create
    @announcement = Announcement.new(announcement_params)

    if @announcement.save
      render :show
    else
      render json: { status: :error, message: @announcement.errors.full_messages.join(', ') }
    end
  end

  def last
    @announcement = Announcement.last

    if @announcement.nil?
      render json: { status: :ok, message: 'No announcement to show' }
    else
      render :show
    end
  end

  private

  def announcement_params
    params.require(:announcement).permit(:text)
  end
end
