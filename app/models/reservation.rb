class Reservation < ApplicationRecord
  belongs_to :guest
  accepts_nested_attributes_for :guest

  enum status: %w(accepted other)

  validates :code, presence: true, uniqueness: { scope: :guest_id }

  def as_json(opts = {})
    { only: [:id, :guest_id] }
  end
end
