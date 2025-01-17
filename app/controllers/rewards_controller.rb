class RewardsController < ApplicationController
  before_action :authenticate_request, only: [:index]

  def index
    @rewards ||= Reward.where(node_id: Node.where(user_id: current_user.id).select(:id).map(&:id)).order(timestamp: :desc)
  end
end
