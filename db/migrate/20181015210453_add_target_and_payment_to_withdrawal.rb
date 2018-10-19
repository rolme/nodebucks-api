class AddTargetAndPaymentToWithdrawal < ActiveRecord::Migration[5.2]
  def change
    add_column :withdrawals, :target, :string
    add_column :withdrawals, :payment_type, :string
  end
end
