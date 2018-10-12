json.pending do
  json.partial! 'transaction', collection: @txs_pending, as: :transaction
end

json.processed do
  json.partial! 'transaction', collection: @txs_processed, as: :transaction
end

json.cancelled do
  json.partial! 'transaction', collection: @txs_cancelled, as: :transaction
end

json.pendingTotal Transaction.pending.size
json.processedTotal Transaction.processed.size
json.cancelledTotal Transaction.cancelled.size
