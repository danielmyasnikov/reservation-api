class Reservation < ApplicationRecord
  belongs_to :guest

  enum status: %w(accepted other)
end
