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

ActiveRecord::Schema.define(version: 20180310222025) do

  create_table "audits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes", limit: 65535
    t.integer  "version",                       default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index", using: :btree
    t.index ["auditable_type", "auditable_id"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "bank_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "statement_parser_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["name", "user_id"], name: "index_bank_accounts_on_name_and_user_id", unique: true, using: :btree
    t.index ["statement_parser_id"], name: "fk_rails_38c50f685e", using: :btree
    t.index ["user_id"], name: "fk_rails_92daa8a387", using: :btree
  end

  create_table "bank_statements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                                                  null: false
    t.integer  "bank_account_id",                                          null: false
    t.integer  "month",                                                    null: false
    t.integer  "year",                                                     null: false
    t.decimal  "total_amount",    precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["bank_account_id", "month", "year"], name: "index_bank_statements_on_bank_account_id_and_month_and_year", unique: true, using: :btree
    t.index ["user_id"], name: "fk_rails_39a1c6060b", using: :btree
  end

  create_table "statement_parsers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                                 null: false
    t.text     "description",            limit: 65535
    t.string   "type"
    t.string   "plain_text_regex"
    t.string   "plain_text_date_format"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["name"], name: "index_statement_parsers_on_name", unique: true, using: :btree
  end

  create_table "statement_record_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                      null: false
    t.integer  "user_id",                   null: false
    t.string   "color"
    t.string   "icon"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["user_id"], name: "fk_rails_9942527c5c", using: :btree
  end

  create_table "statement_record_category_rules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                            null: false
    t.string   "type",                            null: false
    t.integer  "user_id",                         null: false
    t.integer  "category_id",                     null: false
    t.string   "pattern",                         null: false
    t.boolean  "case_insensitive"
    t.boolean  "active",           default: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["category_id"], name: "fk_rails_40ff3e417c", using: :btree
    t.index ["user_id"], name: "fk_rails_15b479eb25", using: :btree
  end

  create_table "statement_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id",                                   null: false
    t.integer  "statement_id",                              null: false
    t.integer  "category_id"
    t.integer  "category_rule_id"
    t.decimal  "amount",           precision: 10, scale: 2, null: false
    t.date     "date",                                      null: false
    t.string   "description",                               null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["category_id"], name: "fk_rails_170dd862e1", using: :btree
    t.index ["category_rule_id"], name: "fk_rails_9f7c830a4d", using: :btree
    t.index ["statement_id"], name: "fk_rails_c5a488a3d1", using: :btree
    t.index ["user_id"], name: "fk_rails_15f285568f", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "name",                   default: "", null: false
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  add_foreign_key "bank_accounts", "statement_parsers"
  add_foreign_key "bank_accounts", "users"
  add_foreign_key "bank_statements", "bank_accounts"
  add_foreign_key "bank_statements", "users"
  add_foreign_key "statement_record_categories", "users"
  add_foreign_key "statement_record_category_rules", "statement_record_categories", column: "category_id"
  add_foreign_key "statement_record_category_rules", "users"
  add_foreign_key "statement_records", "bank_statements", column: "statement_id"
  add_foreign_key "statement_records", "statement_record_categories", column: "category_id"
  add_foreign_key "statement_records", "statement_record_category_rules", column: "category_rule_id"
  add_foreign_key "statement_records", "users"
end
