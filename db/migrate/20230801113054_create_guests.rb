class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.string :first_name
      t.string :last_name
      t.text :phone, array: true, null: false, default: []
      t.string :email

      t.timestamps
    end
  end
end
