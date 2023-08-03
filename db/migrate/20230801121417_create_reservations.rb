# frozen_string_literal: true

class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.string :code
      t.date :start_date
      t.date :end_date
      t.float :payout_price
      t.float :security_price
      t.float :total_price
      t.string :currency
      t.integer :nights
      t.integer :guests
      t.integer :adults
      t.integer :children
      t.integer :infants
      t.string :status
      t.references :guest, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reservations, %i[code guest_id], unique: true
    add_index :reservations, :status, using: 'btree'
  end
end
