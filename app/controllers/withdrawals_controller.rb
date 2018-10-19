class WithdrawalsController < ApplicationController
  before_action :authenticate_request, only: [:confirm, :create, :index, :show]
  before_action :authenticate_admin_request, only: [:update]

  def confirm
    withdrawal_manager = WithdrawalManager.new(current_user)
    if withdrawal_manager.confirm(withdrawal_params)
      @withdrawal = withdrawal_manager.withdrawal
      SupportMailerService.send_withdrawal_requested_notification(current_user, @withdrawal)
      render :show
    else
      render json: { status: :error, message: withdrawal_manager.error }
    end
  end

  def create
    withdrawal_manager = WithdrawalManager.new(current_user)
    if withdrawal_manager.save
      @withdrawal = withdrawal_manager.withdrawal
      render :show
    else
      render json: { status: :error, message: @withdrawal.error }
    end
  end

  def index
    @withdrawals   = Withdrawal.all if current_user.admin? && params.has_key?(:all)
    @withdrawals ||= Withdrawal.where(user_id: current_user.id).where.not(status: :reserved)
  end

  def show
    @withdrawal = Withdrawal.find_by(slug: params[:slug])
  end

  def update
    withdrawal_manager = WithdrawalManager.new(current_user, withdrawal)
    if withdrawal_manager.update(admin_withdrawal_params)
      @withdrawal = withdrawal_manager.withdrawal
      render :show
    else
      render json: { status: :error, message: withdrawal_manager.error }
    end
  end

protected

  def admin_withdrawal_params
    params.require(:withdrawal).permit(:status)
  end

  def withdrawal_params
    params.require(:withdrawal).permit(:target, :payment_type, :password)
  end

  def withdrawal
    @withdrawal ||= Withdrawal.find_by(slug: params[:slug])
  end

end
