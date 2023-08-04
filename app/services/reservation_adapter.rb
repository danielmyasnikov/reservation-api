# frozen_string_literal: true

class ReservationAdapter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  SERVICES = [
    ReservationServiceOne,
    ReservationServiceTwo
  ].freeze
  def find_service
    @find_service ||= SERVICES.find { |service| service.new(params).valid? }
  end
end
