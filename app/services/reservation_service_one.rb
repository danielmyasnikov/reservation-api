# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ReservationServiceOne
  attr_reader :params, :dub_permitted_params

  def valid?
    JSON::Validator.validate(valid_schema, dub_permitted_params.to_h, strict: true)
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
  def permitted_params
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
    @dub_permitted_params = permitted_params.dup
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
    dub_permitted_params[:guest][:phone] = [dub_permitted_params[:guest][:phone]] unless dub_permitted_params[:guest][:phone].is_a?(Array)
    dub_permitted_params[:guest]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def reservation_mapped_params
    {
      code: dub_permitted_params[:reservation_code],
      start_date: dub_permitted_params[:start_date],
      end_date: dub_permitted_params[:end_date],
      nights: dub_permitted_params[:nights],
      guests: dub_permitted_params[:guests],
      adults: dub_permitted_params[:adults],
      children: dub_permitted_params[:children],
      infants: dub_permitted_params[:infants],
      status: dub_permitted_params[:status],
      currency: dub_permitted_params[:currency],
      payout_price: dub_permitted_params[:payout_price],
      security_price: dub_permitted_params[:security_price],
      total_price: dub_permitted_params[:total_price]
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
