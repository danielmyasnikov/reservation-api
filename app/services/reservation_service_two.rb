# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ReservationServiceTwo
  attr_reader :params

  def valid?
    JSON::Validator.validate(valid_schema, permit_params.to_h, strict: true)
  end

  # rubocop:disable Metrics/MethodLength
  def valid_schema
    {
      type: 'object',
      properties: {
        code: { type: %w[string null] },
        start_date: { type: %w[string null] },
        end_date: { type: %w[string null] },
        listing_security_price_accurate: { type: %w[string null] },
        host_currency: { type: %w[string null] },
        nights: { type: %w[string null] },
        number_of_guests: { type: %w[string null] },
        status_type: { type: %w[string null] },
        total_paid_amount_accurate: { type: %w[string null] },
        expected_payout_amount: { type: %w[string null] },
        guest_email: { type: %w[string null] },
        guest_first_name: { type: %w[string null] },
        guest_last_name: { type: %w[string null] },
        guest_phone_numbers: { type: ['array'] },
        guest_details: {
          type: 'object',
          properties: {
            number_of_adults: { type: %w[string null] },
            number_of_children: { type: %w[string null] },
            number_of_infants: { type: %w[string null] }
          }
        }
      }
    }
  end

  def permit_params
    params.fetch(:reservation, {}).permit(
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
    ).reverse_merge!({ guest_phone_numbers: [] })
  end

  def initialize(params)
    @params = params
  end

  def call
    if found_guest_and_reservation?
      @guest.update!(update_params)
    elsif found_guest?
      @guest.update!(upsert_params)
    else
      @guest = Guest.create!(create_params)
    end

    @guest
  end

  def guest_params
    {
      email: permit_params[:guest_email],
      first_name: permit_params[:guest_first_name],
      last_name: permit_params[:guest_last_name],
      phone: permit_params[:guest_phone_numbers]
    }
  end

  # rubocop:disable Metrics/AbcSize
  def reservation_mapped_params
    {
      code: permit_params[:code],
      start_date: permit_params[:start_date],
      end_date: permit_params[:end_date],
      nights: permit_params[:nights],
      guests: permit_params[:number_of_guests],
      adults: permit_params[:guest_details][:number_of_adults],
      children: permit_params[:guest_details][:number_of_children],
      infants: permit_params[:guest_details][:number_of_infants],
      status: permit_params[:status_type],
      currency: permit_params[:host_currency],
      payout_price: permit_params[:expected_payout_amount],
      security_price: permit_params[:listing_security_price_accurate],
      total_price: permit_params[:total_paid_amount_accurate]
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def create_params
    guest_params.merge(reservations_attributes: [reservation_mapped_params])
  end

  def upsert_params
    create_params
  end

  def update_params
    guest_params.merge(reservations_attributes: [reservation_mapped_params.merge(id: @reservation.id)])
  end

  def found_guest_and_reservation?
    return unless (@guest = guest)
    return unless (@reservation = @guest.reservations.find_by(code: permit_params[:code]))

    true
  end

  def found_guest?
    return unless guest

    true
  end

  def guest
    @guest ||= Guest.find_by(email: permit_params[:guest_email])
  end
end
# rubocop:enable Metrics/ClassLength
