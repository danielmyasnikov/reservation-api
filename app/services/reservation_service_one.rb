# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ReservationServiceOne
  attr_reader :params

  def valid?
    JSON::Validator.validate(valid_schema, permit_params.to_h, strict: true)
  end

  # rubocop:disable Metrics/MethodLength
  def valid_schema
    {
      type: 'object',
      properties: {
        reservation_code: { type: %w[string null] },
        start_date: { type: %w[string null] },
        end_date: { type: %w[string null] },
        nights: { type: %w[string integer null] },
        guests: { type: %w[string integer null] },
        adults: { type: %w[string integer null] },
        children: { type: %w[string integer null] },
        infants: { type: %w[string integer null] },
        status: { type: %w[string null] },
        currency: { type: %w[string null] },
        payout_price: { type: %w[string null] },
        security_price: { type: %w[string null] },
        total_price: { type: %w[string null] },
        guest: {
          type: 'object',
          properties: {
            first_name: { type: %w[string null] },
            last_name: { type: %w[string null] },
            email: { type: %w[string null] },
            phone: { type: %w[string null] }
          }
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def permit_params
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
    permit_params[:guest][:phone] = [permit_params[:guest][:phone]] unless permit_params[:guest][:phone].is_a?(Array)
    permit_params[:guest]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def reservation_mapped_params
    {
      code: permit_params[:reservation_code],
      start_date: permit_params[:start_date],
      end_date: permit_params[:end_date],
      nights: permit_params[:nights],
      guests: permit_params[:guests],
      adults: permit_params[:adults],
      children: permit_params[:children],
      infants: permit_params[:infants],
      status: permit_params[:status],
      currency: permit_params[:currency],
      payout_price: permit_params[:payout_price],
      security_price: permit_params[:security_price],
      total_price: permit_params[:total_price]
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
    return unless (@reservation = @guest.reservations.find_by(code: params[:reservation_code]))

    true
  end

  def found_guest?
    return unless guest

    true
  end

  def guest
    @guest ||= Guest.find_by(email: params[:guest][:email])
  end
end
# rubocop:enable Metrics/ClassLength
