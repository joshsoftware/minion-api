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

ActiveRecord::Schema.define(version: 2020_09_02_131804) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "agent_configurations", primary_key: ["id", "server_id"], force: :cascade do |t|
    t.uuid "id", null: false
    t.uuid "server_id", null: false
    t.json "configuration", default: "{}", null: false
    t.string "source", default: "admin", null: false
    t.integer "version", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "agent_versions", force: :cascade do |t|
    t.string "version", null: false
    t.string "md5", null: false
    t.string "url", null: false
  end

  create_table "blacklisted_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_blacklisted_tokens_on_token"
  end

  create_table "command_queues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "command_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_command_queues_on_created_at"
  end

  create_table "command_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "stdout", null: false, array: true
    t.string "hash", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stderr", default: [], null: false, array: true
    t.index ["hash"], name: "index_command_responses_on_hash", unique: true
  end

  create_table "commands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "argv", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "external", null: false
  end

  create_table "logs", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "server_id", null: false
    t.string "service", null: false
    t.string "msg", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.tsvector "tsv"
    t.index ["msg"], name: "logs_msg_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["service"], name: "index_logs_on_service"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
  end

  create_table "servers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aliases", array: true
    t.string "addresses", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "organization_id"
    t.datetime "discarded_at"
    t.datetime "heartbeat_at"
    t.index ["discarded_at"], name: "index_servers_on_discarded_at"
    t.index ["organization_id"], name: "index_servers_on_organization_id"
  end

  create_table "servers_commands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "server_id", null: false
    t.uuid "command_id", null: false
    t.uuid "response_id"
    t.datetime "dispatched_at"
    t.datetime "response_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["command_id"], name: "index_servers_commands_on_command_id"
    t.index ["response_id"], name: "index_servers_commands_on_response_id"
    t.index ["server_id"], name: "index_servers_commands_on_server_id"
  end

  create_table "servers_tags", force: :cascade do |t|
    t.uuid "server_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "telemetries", primary_key: ["server_id", "id"], force: :cascade do |t|
    t.uuid "server_id", null: false
    t.uuid "id", null: false
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "created_at_idx"
    t.index ["data"], name: "data_idx", using: :gin
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
    t.boolean "administration", default: false, null: false
    t.string "salt", default: "", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["mobile_number"], name: "index_users_on_mobile_number"
    t.index ["role"], name: "index_users_on_role"
  end

end
