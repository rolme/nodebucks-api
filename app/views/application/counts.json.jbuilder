json.cryptos Crypto.active.count
json.nodes Node.unreserved.count
json.pendingWithdrawals Withdrawal.pending.count
json.users User.where.not(email: nil).count
json.verifications User.where.not(email: nil).verifications_pending.count
json.pendingTransactions Transaction.pending.count
json.contacts Contact.unreviewed.count
json.unpaidOrders Order.unpaid.count
json.ordersAll Order.count
