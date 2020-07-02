# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_02_070204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "agent_configurations", primary_key: ["id", "server_id"], force: :cascade do |t|
    t.uuid "id", null: false
    t.uuid "server_id", null: false
    t.json "configuration", default: "{}", null: false
    t.string "source", default: "admin", null: false
    t.integer "version", default: 0, null: false
  end

  create_table "blacklisted_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_blacklisted_tokens_on_token"
  end

  create_table "logs", primary_key: ["id", "server_id"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.uuid "server_id", null: false
    t.uuid "uuid", null: false
    t.string "service", null: false
    t.string "msg", null: false
  end

  create_table "organization_users", force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
  end

  create_table "servers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aliases", array: true
    t.inet "addresses", array: true
  end

  create_table "servers_tags", force: :cascade do |t|
    t.uuid "server_id", null: false
    t.bigint "tag_id", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag", null: false
  end

  create_table "telemetries", primary_key: ["server_id", "uuid"], force: :cascade do |t|
    t.uuid "server_id", null: false
    t.uuid "uuid", null: false
    t.jsonb "data"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "mobile_number"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["mobile_number"], name: "index_users_on_mobile_number"
    t.index ["role"], name: "index_users_on_role"
  end

end
