class AddIssueIdToAuthors < ActiveRecord::Migration[5.2]
  def change
    change_table :authors do |t|
      t.integer :issue_id
    end
  end
end
