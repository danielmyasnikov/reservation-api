# frozen_string_literal: true

class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.string :first_name
      t.string :last_name
      t.text :phone, array: true, null: false, default: []
      t.string :email, null: false

      t.timestamps
    end

    add_index :guests, :email, using: 'btree'
  end
end
