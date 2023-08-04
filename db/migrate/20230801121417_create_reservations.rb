# frozen_string_literal: true

class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.string :code
      t.date :start_date
      t.date :end_date
      t.float :payout_price, default: 0.0
      t.float :security_price, default: 0.0
      t.float :total_price, default: 0.0
      t.string :currency
      t.integer :nights, default: 0
      t.integer :guests, default: 0
      t.integer :adults, default: 0
      t.integer :children, default: 0
      t.integer :infants, default: 0
      t.string :status, default: :draft
      t.references :guest, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reservations, %i[code guest_id], unique: true
    add_index :reservations, :status, using: 'btree'
  end
end
