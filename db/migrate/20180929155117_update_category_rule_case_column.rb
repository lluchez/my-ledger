class UpdateCategoryRuleCaseColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :statement_record_category_rules, :case_insensitive, :boolean, null: false, default: false
    rename_column :statement_record_category_rules, :case_insensitive, :case_sensitive
  end

  def down
    change_column :statement_record_category_rules, :case_sensitive, :boolean, null: true, default: nil
    rename_column :statement_record_category_rules, :case_sensitive, :case_insensitive
  end
end
