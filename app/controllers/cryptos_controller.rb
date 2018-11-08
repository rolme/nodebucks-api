class CryptosController < ApplicationController
  before_action :authenticate_request_optional, only: [:show]
  before_action :authenticate_admin_request, only: [:update, :delist, :relist]

  def index
    @cryptos = Crypto.active
  end

  def show
    @crypto   = Crypto.find_by(slug: params[:slug])
    @show_roi = true

    if params[:orders]&.to_bool && @current_user&.admin
      @show_pricing = true
      @orders

      np = NodeManager::Pricer.new(persist: true)
      np.evaluate(@crypto)
      @orders = np.orders
    end
  end

  def purchasable_statuses
    render json: Crypto::PURCHASABLE_STATUSES
  end

  def update
    @crypto = Crypto.find_by(slug: params[:slug])
    if @crypto.update(crypto_params)
      render :show
    else
      render json: { status: :error, message: @crypto.error }
    end
  end

  def relist
    @crypto = Crypto.find_by(slug: params[:crypto_slug])
    if @crypto.update_attribute(:is_listed, true)
      render :show
    else
      render json: { status: :error, message: @crypto.error }
    end
  end

  def delist
    @crypto = Crypto.find_by(slug: params[:crypto_slug])
    if @crypto.update_attribute(:is_listed, false)
      render :show
    else
      render json: { status: :error, message: @crypto.error }
    end
  end

  def test_reward_scraper
    @crypto = Crypto.find_by(slug: params[:crypto_slug])
    render json: TestRewarder.new(@crypto, params[:wallet], Time.parse(params[:date])).check
  end

  def prices
    @crypto = Crypto.find_by(slug: params[:crypto_slug])
    @prices = @crypto.crypto_price_histories

    if @prices.any?
      render json: CryptoPriceHistory.averages(@prices.by_days(params[:days].to_i).by_timeframe(params[:timeframe]))
    else
      render json: { status: :error, message: "No price history for #{crypto.name}" }
    end
  end

  private

  def crypto_params
    params.require(:crypto).permit(
      :description,
      :first_reward_days,
      :is_listed,
      :profile,
      :logo_url,
      :name,
      :purchasable_status,
      :status,
      :url
    )
  end
end
