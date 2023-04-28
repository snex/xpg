# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_28_003030) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "amount", null: false
    t.datetime "expires_at", null: false
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_invoices_on_external_id", unique: true
    t.index ["wallet_id"], name: "index_invoices_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.string "name", null: false
    t.string "password", null: false
    t.string "rpc_creds", null: false
    t.integer "port", null: false
    t.integer "pid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ready_to_run", default: false, null: false
    t.index ["name"], name: "index_wallets_on_name", unique: true
    t.index ["port"], name: "index_wallets_on_port", unique: true
  end

  add_foreign_key "invoices", "wallets"
end
