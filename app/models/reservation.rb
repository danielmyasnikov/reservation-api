# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :guest
  accepts_nested_attributes_for :guest

  STATUSES = %w[accepted other].freeze
  enum status: STATUSES.zip(STATUSES).to_h

  validates :code, presence: true, uniqueness: { scope: :guest_id }

  def as_json(_opts = {})
    { only: %i[id guest_id] }
  end
end
