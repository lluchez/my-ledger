class AddingModels < ActiveRecord::Migration[5.0]
  def up
    # table bank_statements
    create_table :bank_statements do |t|
      t.integer :user_id,         :null => false
      t.integer :bank_account_id, :null => false
      t.integer :month,           :null => false
      t.integer :year,            :null => false
      t.decimal :total_amount,    :null => false, :default => 0, :precision => 10, :scale => 2
      t.timestamps
    end

    add_index :bank_statements, [:bank_account_id, :month, :year], unique: true
    add_foreign_key :bank_statements, :users
    add_foreign_key :bank_statements, :bank_accounts


    # table statement_record_categories
    create_table :statement_record_categories do |t|
      t.string  :name,    :null => false
      t.integer :user_id, :null => false
      t.string  :color
      t.string  :icon
      t.boolean :active, :default => true
      t.timestamps
    end

    add_foreign_key :statement_record_categories, :users


    # table statement_record_category_rules
    create_table :statement_record_category_rules do |t|
      t.string  :name,        :null => false
      t.string  :type,        :null => false
      t.integer :user_id,     :null => false
      t.integer :category_id, :null => false
      t.string  :pattern,     :null => false
      t.boolean :case_insensitive
      t.boolean :active,      :default => true
      t.timestamps
    end

    add_foreign_key :statement_record_category_rules, :users
    add_foreign_key :statement_record_category_rules, :statement_record_categories, :column => :category_id


    # table statement_records
    create_table :statement_records do |t|
      t.integer :user_id,          :null => false
      t.integer :statement_id,     :null => false
      t.integer :category_id
      t.integer :category_rule_id
      t.decimal :amount,           :null => false, :precision => 10, :scale => 2
      t.date    :date,             :null => false
      t.string  :description,      :null => false
      t.timestamps
    end

    add_foreign_key :statement_records, :users
    add_foreign_key :statement_records, :bank_statements, :column => :statement_id
    add_foreign_key :statement_records, :statement_record_categories, :column => :category_id
    add_foreign_key :statement_records, :statement_record_category_rules, :column => :category_rule_id
  end

  def down
    drop_table :statement_records
    drop_table :statement_record_category_rules
    drop_table :statement_record_categories
    drop_table :bank_statements
  end
end
