# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_16_235616) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "crypto_id"
    t.string "slug"
    t.string "wallet"
    t.decimal "balance", default: "0.0"
    t.string "cached_crypto_symbol"
    t.string "cached_crypto_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crypto_id"], name: "index_accounts_on_crypto_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "affiliates", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "affiliate_user_id"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_affiliates_on_user_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string "subject"
    t.string "email"
    t.text "message"
    t.integer "reviewed_by_user"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_by_user"], name: "index_contacts_on_reviewed_by_user"
  end

  create_table "crypto_price_histories", force: :cascade do |t|
    t.bigint "crypto_id"
    t.decimal "circulating_supply"
    t.decimal "total_supply"
    t.decimal "max_supply"
    t.decimal "price_usd"
    t.decimal "volume_24h"
    t.decimal "market_cap"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crypto_id"], name: "index_crypto_price_histories_on_crypto_id"
  end

  create_table "crypto_prices", force: :cascade do |t|
    t.bigint "crypto_id"
    t.integer "amount"
    t.decimal "btc", default: "0.0"
    t.decimal "usdt", default: "0.0"
    t.string "price_type", default: "buy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crypto_id"], name: "index_crypto_prices_on_crypto_id"
  end

  create_table "cryptos", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.string "symbol"
    t.string "url"
    t.string "logo_url"
    t.string "status", default: "active"
    t.bigint "masternodes"
    t.decimal "node_price", default: "0.0"
    t.decimal "daily_reward"
    t.string "description"
    t.decimal "block_reward"
    t.decimal "price", default: "0.0"
    t.decimal "sellable_price", default: "0.0"
    t.decimal "estimated_price", default: "0.0"
    t.decimal "estimated_node_price", default: "0.0"
    t.decimal "flat_setup_fee", default: "0.0"
    t.decimal "percentage_setup_fee", default: "0.05"
    t.decimal "percentage_hosting_fee", default: "0.0295"
    t.decimal "percentage_conversion_fee", default: "0.03"
    t.integer "stake", default: 1000
    t.decimal "purchasable_price", default: "0.0"
    t.string "explorer_url"
    t.string "ticker_url"
    t.decimal "market_cap", precision: 15, scale: 1
    t.decimal "volume", precision: 15, scale: 1
    t.decimal "available_supply", precision: 15, scale: 1
    t.decimal "total_supply", precision: 15, scale: 1
    t.text "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "buy_liquidity", default: true
    t.boolean "sell_liquidity", default: true
    t.decimal "percentage_decommission_fee", default: "0.0"
    t.decimal "node_sell_price"
    t.string "purchasable_status", default: "Unavailable"
    t.integer "first_reward_days", default: 0
    t.decimal "node_sell_price_btc", default: "0.0"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "node_id"
    t.string "event_type"
    t.string "description"
    t.decimal "value", default: "0.0"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_events_on_node_id"
  end

  create_table "node_price_histories", force: :cascade do |t|
    t.bigint "node_id"
    t.jsonb "data", default: {}, null: false
    t.string "source"
    t.decimal "value", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_node_price_histories_on_node_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "crypto_id"
    t.bigint "user_id"
    t.integer "created_by_admin_id"
    t.string "cached_crypto_name"
    t.string "cached_crypto_symbol"
    t.string "cached_user_slug"
    t.string "slug"
    t.string "status", default: "new"
    t.string "ip"
    t.decimal "cost"
    t.decimal "balance", default: "0.0"
    t.decimal "wallet_balance", default: "0.0"
    t.datetime "online_at"
    t.datetime "sold_at"
    t.datetime "disbursed_at"
    t.string "wallet"
    t.string "version"
    t.datetime "last_upgraded_at"
    t.string "vps_provider"
    t.string "vps_url"
    t.decimal "vps_monthly_cost"
    t.string "withdraw_wallet"
    t.integer "reward_setting", default: 0
    t.integer "sell_setting", default: 0
    t.string "sell_bitcoin_wallet"
    t.decimal "sell_price"
    t.string "stripe"
    t.datetime "sell_priced_at"
    t.datetime "buy_priced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "online_mail_sent_at"
    t.decimal "nb_buy_amount", default: "0.0"
    t.decimal "nb_sell_amount", default: "0.0"
    t.decimal "sell_price_btc", default: "0.0"
    t.index ["account_id"], name: "index_nodes_on_account_id"
    t.index ["crypto_id"], name: "index_nodes_on_crypto_id"
    t.index ["slug"], name: "index_nodes_on_slug"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "node_id"
    t.string "slug"
    t.string "order_type"
    t.decimal "amount"
    t.string "currency"
    t.string "status"
    t.string "target"
    t.string "description"
    t.string "payment_method"
    t.text "paypal_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_orders_on_node_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "node_id"
    t.string "cached_crypto_name"
    t.string "cached_crypto_symbol"
    t.datetime "timestamp"
    t.string "txhash"
    t.decimal "amount"
    t.decimal "fee"
    t.decimal "total_amount"
    t.decimal "usd_value", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "notification_sent_at"
    t.decimal "balance", default: "0.0"
    t.integer "node_reward_setting", default: 0
    t.boolean "user_notification_setting_on", default: true
    t.index ["node_id"], name: "index_rewards_on_node_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "reward_id"
    t.bigint "withdrawal_id"
    t.string "txn_type"
    t.string "slug"
    t.decimal "amount"
    t.string "cached_crypto_name"
    t.string "cached_crypto_symbol"
    t.string "notes"
    t.string "status", default: "pending"
    t.datetime "cancelled_at"
    t.datetime "processed_at"
    t.integer "last_modified_by_admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "usd_value"
    t.decimal "btc_value"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["reward_id"], name: "index_transactions_on_reward_id"
    t.index ["withdrawal_id"], name: "index_transactions_on_withdrawal_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first"
    t.string "last"
    t.string "email"
    t.string "password_digest"
    t.string "nickname"
    t.boolean "admin", default: false
    t.boolean "accessible", default: true
    t.string "slug"
    t.datetime "confirmed_at"
    t.string "reset_token"
    t.datetime "reset_at"
    t.datetime "deleted_at"
    t.string "new_email"
    t.string "avatar"
    t.string "facebook"
    t.string "google"
    t.string "linkedin"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "country"
    t.integer "upline_user_id"
    t.decimal "affiliate_earnings", default: "0.0"
    t.decimal "affiliate_balance", default: "0.0"
    t.string "affiliate_key"
    t.datetime "affiliate_key_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "two_fa_secret"
    t.datetime "verified_at"
    t.string "verification_status", default: "none"
    t.string "verification_image"
    t.boolean "reward_notification_on", default: true
    t.boolean "enabled", default: false
    t.index ["affiliate_key"], name: "index_users_on_affiliate_key", unique: true
  end

  create_table "withdrawals", force: :cascade do |t|
    t.bigint "user_id"
    t.string "slug"
    t.json "balances", default: {}
    t.decimal "amount_btc", default: "0.0"
    t.decimal "amount_usd", default: "0.0"
    t.string "status", default: "reserved"
    t.integer "last_modified_by_admin_id"
    t.datetime "processed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "affiliate_balance", default: "0.0"
    t.string "target"
    t.string "payment_type"
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

  add_foreign_key "accounts", "cryptos"
  add_foreign_key "accounts", "users"
  add_foreign_key "affiliates", "users"
  add_foreign_key "crypto_price_histories", "cryptos"
  add_foreign_key "crypto_prices", "cryptos"
  add_foreign_key "events", "nodes"
  add_foreign_key "node_price_histories", "nodes"
  add_foreign_key "orders", "nodes"
  add_foreign_key "orders", "users"
  add_foreign_key "rewards", "nodes"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "rewards"
  add_foreign_key "transactions", "withdrawals"
  add_foreign_key "withdrawals", "users"
end
