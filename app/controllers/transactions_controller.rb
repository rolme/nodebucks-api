class TransactionsController < ApplicationController
  before_action :authenticate_admin_request, only: [:index, :process, :update, :undo]

  def index
    @txs_pending = Transaction.pending.includes(account: :user).order(created_at: :desc).limit(params[:limit].to_i || 25).offset((params[:page].to_i || 0) * 25)
    @txs_processed = Transaction.processed.includes(account: :user).order(created_at: :desc).limit(params[:limit].to_i || 25).offset((params[:page].to_i || 0) * 25)
    @txs_cancelled = Transaction.cancelled.includes(account: :user).order(created_at: :desc).limit(params[:limit].to_i || 25).offset((params[:page].to_i || 0) * 25)
  end

  def update
    @transaction   = Transaction.find(params[:id])
    @transaction ||= Transaction.find_by(slug: params[:slug])
    if @transaction.update(transaction_params)
      render :show
    else
      render json: { status: 'error', message: @transaction.errors.full_messages.join(', ') }
    end
  end

  def processed
    @transaction = Transaction.find_by(slug: params[:transaction_slug])
    @transaction.process!
    if @transaction.withdrawal.present?
      unprocessed = @transaction.withdrawal.transactions.reject{ |t| t.status == 'processed' }.count
      @transaction.withdrawal.update_attribute(:status, 'processed') if unprocessed == 0
    end

    render :show
  end

  def undo
    @transaction = Transaction.find_by(slug: params[:transaction_slug])
    @transaction.undo!
    @transaction.withdrawal.present? && @transaction.withdrawal.update_attribute(:status, 'pending')

    render :show
  end


  def transaction_params
    params.require(:transaction).permit(
      :status,
      :notes,
      :amount,
    )
  end
end
