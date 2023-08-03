# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :guest
  accepts_nested_attributes_for :guest

  STATUSES = %w[accepted other].freeze
  enum status: STATUSES.zip(STATUSES).to_h

  validates :code, presence: true, uniqueness: { scope: :guest_id }

  validate :email_reservation_code!

  def email_reservation_code!
    dublicate = Guest.joins(:reservations)
                     .where.not(id: guest.id)
                     .where(email: guest.email)
                     .where(reservations: { code: code })
                     .any?

    errors.add(:code, 'reservation for this guest exist') if dublicate
  end

  def as_json(_opts = {})
    { only: %i[id guest_id] }
  end
end
