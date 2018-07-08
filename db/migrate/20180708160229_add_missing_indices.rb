class AddMissingIndices < ActiveRecord::Migration[5.2]
  def change
    add_index(:statement_record_categories, [:user_id, :name], unique: true)
    add_index(:statement_record_category_rules, [:user_id, :name], unique: true)
    add_index(:bank_statements, [:bank_account_id])
  end
end
