# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140423202012) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider",      null: false
    t.string   "proid",         null: false
    t.string   "token"
    t.string   "refresh_token"
    t.string   "secret"
    t.datetime "expires_at"
    t.string   "username"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider"], :name => "index_authentications_on_provider"
    t.index ["user_id"], :name => "fk__authentications_user_id"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image_url"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin"
    t.index ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
    t.index ["email"], :name => "index_users_on_email", :unique => true, :case_sensitive => false
    t.index ["is_admin"], :name => "index_users_on_is_admin"
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    t.index ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  end

  create_table "bundles", force: true do |t|
    t.integer  "user_id",                           null: false
    t.string   "name",                              null: false
    t.string   "description",                       null: false
    t.boolean  "deploy",            default: false
    t.integer  "num",               default: 1
    t.integer  "vcpu",              default: 1
    t.integer  "memory",            default: 64
    t.string   "original_filename",                 null: false
    t.string   "mime_type",                         null: false
    t.integer  "size",                              null: false
    t.boolean  "fail",              default: false
    t.string   "fail_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__bundles_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bundles_user_id"
  end

  create_table "bundle_bodies", force: true do |t|
    t.integer  "bundle_id"
    t.binary   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bundle_id"], :name => "fk__bundle_bodies_bundle_id"
    t.foreign_key ["bundle_id"], "bundles", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bundle_bodies_bundle_id"
  end

  create_table "nodes", force: true do |t|
    t.string   "uuid",                         null: false
    t.string   "session"
    t.string   "address"
    t.boolean  "active",       default: false
    t.datetime "activated_at"
    t.integer  "cpu_usage",    default: 0
    t.integer  "memory_usage", default: 0
    t.integer  "free_memory",  default: 0
    t.integer  "free_vcpu",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", force: true do |t|
    t.integer  "bundle_id",                     null: false
    t.integer  "node_id",                       null: false
    t.boolean  "pending",       default: true
    t.boolean  "terminate",     default: false
    t.boolean  "active",        default: false
    t.string   "address"
    t.string   "command_line"
    t.string   "node_session"
    t.string   "status"
    t.datetime "activated_at"
    t.datetime "terminated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bundle_id"], :name => "fk__instances_bundle_id"
    t.index ["node_id"], :name => "fk__instances_node_id"
    t.foreign_key ["bundle_id"], "bundles", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_instances_bundle_id"
    t.foreign_key ["node_id"], "nodes", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_instances_node_id"
  end

  create_table "oauth_caches", id: false, force: true do |t|
    t.integer  "authentication_id", null: false
    t.text     "data_json",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["authentication_id"], :name => "index_oauth_caches_on_authentication_id"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], :name => "index_rails_admin_histories"
  end

end
