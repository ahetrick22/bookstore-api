class AddBiographyToAuthors < ActiveRecord::Migration[5.2]
  def change
    change_table :authors do |t|
      t.string :biography
    end
  end
end
