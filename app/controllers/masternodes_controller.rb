class MasternodesController < ApplicationController
  def index
    @masternodes = Crypto.select(:name, :description, :logo_url, :slug, :price, :url, :first_reward_days).all
  end

  def show
    @masternode = Crypto.find_by(slug: params[:slug])
    @user = User.find_by(slug: params[:user_slug])
  end
end
