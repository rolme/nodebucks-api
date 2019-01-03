class RewardsController < ApplicationController
  before_action :authenticate_request, only: [:index]

  def index
    @rewards ||= Reward.where(id: Node.where(user_id: current_user.id, deleted_at: nil, status: ['offline', 'online']).select(:id)).order(timestamp: :desc)
  end
end
