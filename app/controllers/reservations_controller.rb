# frozen_string_literal: true

class ReservationsController < ApplicationController
  def create_or_update
    unless (@service = ReservationAdapter.new(params).find_service)
      raise ActionController::BadRequest, "Unknow format. Params given: #{params}"
    end

    reservation = @service.new(params).call

    render json: { reservation: reservation }, status: :created
  end
end
