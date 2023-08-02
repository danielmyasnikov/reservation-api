class ReservationsController < ApplicationController
  # FIXME: method overload
  #   requires separation of logic into
  #   Endpoint 1. Create entities via format one
  #   Endpoint 2. Create entities via format one
  #   Endpoint 3. Update reservation via format one
  #   Endpoint 4. Update reservation via format two
  def create
    if request_format_one?
      ReservationServiceOne.call(params)
    elsif request_format_two?
      ReservationServiceTwo.call(params)
    end
  end

  private

  def request_format_one?
    params[:reservation_code].present?
  end

  def request_format_two?
    params[:reservation].present? && params[:reservation][:code].present?
  end
end
