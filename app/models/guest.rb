# frozen_string_literal: true

class Guest < ApplicationRecord
  has_many :reservations, dependent: nil
  validates_associated :reservations
  accepts_nested_attributes_for :reservations

  validates :email, presence: true

  def as_json(options = {})
    options[:include] = { reservations: { only: :id } }
    options[:only] = [:id]

    super
  end
end
