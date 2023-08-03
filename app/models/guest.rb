# frozen_string_literal: true

class Guest < ApplicationRecord
  has_many :reservations, dependent: nil
  validates_associated :reservations

  validates :email, presence: true
end
