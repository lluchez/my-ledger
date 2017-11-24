class AddInitialTables < ActiveRecord::Migration[5.0]
  def change

    # user table
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :name,               null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.timestamps null: false
    end
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true


    # statement-parsers table
    create_table :statement_parsers do |t|
      t.string :name, :null => false
      t.text   :description
      t.string :type

      # PlainText Parsers field
      t.string :plain_text_regex
      t.string :plain_text_date_format

      t.timestamps
    end
    add_index :statement_parsers, :name, unique: true


    # Adding default parsers
    StatementParsers::PlainTextParser.create(
      :name => "Discover Credit Card Parser",
      :plain_text_regex => "(?<date>[A-Z][a-z]+ \d+)(?:\s+[A-Z][a-z]+\s+\d+\s+)(?<description>.*?)(?:\s+\$)?\s+(?<amount>\-?\d+(?:\.\d+)?)",
      :plain_text_date_format => "%b %-d")
    StatementParsers::PlainTextParser.create(
      :name => "Chase Credit Card Parser",
      :plain_text_regex => "(?<date>\d+\/\d+)?\s+(?<description>.*?)(?:\s+\$)?\s+(?<amount>\-?\d+(?:\.\d+)?)",
      :plain_text_date_format => "%m/%-d")

    # bank-accounts table
    create_table :bank_accounts do |t|
      t.string :name
      t.integer :user_id
      t.integer :statement_parser_id

      t.timestamps
    end

    add_index :bank_accounts, [:name, :user_id], unique: true
    add_foreign_key :bank_accounts, :users
    add_foreign_key :bank_accounts, :statement_parsers

  end
end
