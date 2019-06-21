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

ActiveRecord::Schema.define(version: 2019_06_20_025711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "description"
    t.integer "price", default: 0
    t.bigint "purchase_id"
    t.index ["purchase_id"], name: "index_items_on_purchase_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.string "address"
  end

  create_table "purchasers", force: :cascade do |t|
    t.string "name"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer "count", default: 0
    t.bigint "merchant_id"
    t.bigint "purchaser_id"
    t.index ["merchant_id"], name: "index_purchases_on_merchant_id"
    t.index ["purchaser_id"], name: "index_purchases_on_purchaser_id"
  end

end
