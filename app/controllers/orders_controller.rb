class OrdersController < ApplicationController
  before_action :authenticate_request, only: [:index, :show]
  before_action :find_order, only: [:paid, :unpaid]

  def index
    if current_user.admin? && params.has_key?(:all)
      @orders = Order.includes(:node, :user)
                  .filter_by_node(params[:n])
                  .filter_by_user(params[:u])
                  .limit(params[:limit].to_i || 25)
                  .offset((params[:page].to_i || 0) * 25)
    else
      @orders = Order.includes(:node, :user).where(user_id: current_user.id)
    end
  end

  def show
    @order   = Order.includes(:node, :user).find_by(slug: params[:slug]) if current_user.admin?
    @order ||= Order.includes(:node, :user).find_by(slug: params[:slug], user_id: current_user.id)
  end

  def paid
    @order.paid!
  end

  def unpaid
    @order.unpaid!
  end

  private

  def find_order
    @order = Order.find_by_slug(params[:order_slug])
  end
end
