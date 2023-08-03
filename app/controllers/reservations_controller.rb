# frozen_string_literal: true

class ReservationsController < ApplicationController
  def create_or_update
    reservation = if request_format_one?
                    ReservationServiceOne.call(service_one_params)
                  elsif request_format_two?
                    ReservationServiceTwo.call(service_two_params)
                  else
                    raise ActionController::BadRequest, "Unknow format. Params given: #{params}"
                  end

    render json: { reservation: reservation }, status: :created
  end

  private

  def request_format_one?
    params[:reservation_code].present?
  end

  def request_format_two?
    params[:reservation].present? && params[:reservation][:code].present?
  end

  # rubocop:disable Metrics/MethodLength
  def service_one_params
    params.permit(
      :reservation_code,
      :start_date,
      :end_date,
      :nights,
      :guests,
      :adults,
      :children,
      :infants,
      :status,
      :currency,
      :payout_price,
      :security_price,
      :total_price,
      guest: %i[
        first_name
        last_name
        phone
        email
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def service_two_params
    params.require(:reservation).permit(
      :code,
      :start_date,
      :end_date,
      :listing_security_price_accurate,
      :host_currency,
      :nights,
      :number_of_guests,
      :status_type,
      :total_paid_amount_accurate,
      :expected_payout_amount,
      :guest_email,
      :guest_first_name,
      :guest_last_name,
      guest_details: %i[
        number_of_adults
        number_of_children
        number_of_infants
      ],
      guest_phone_numbers: []
    )
  end
  # rubocop:enable Metrics/MethodLength
end
