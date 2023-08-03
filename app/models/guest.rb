# frozen_string_literal: true

class Guest < ApplicationRecord
  has_many :reservations

  validates_presence_of :email
end
