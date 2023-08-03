class ReservationServiceTwo
  attr_reader :params

  class UnprocessedEntity < StandardError; end

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
    if found_guest_and_reservation?
      @reservation.assign_attributes(update_reservation_params)
    else
      @guest = Guest.new(guest_params)
      @reservation = @guest.reservations.build(create_reservation_params)
    end
  end

  def call
    ApplicationRecord.transaction do
      @reservation.save!
    end
  end

  def guest_params
    {
      email:      params[:guest_email],
      first_name: params[:guest_first_name],
      last_name:  params[:guest_last_name],
      phone:      params[:guest_phone_numbers]
    }
  end

  def mapped_params
    {
      code:           params[:code],
      start_date:     params[:start_date],
      end_date:       params[:end_date],
      nights:         params[:nights],
      guests:         params[:number_of_guests],
      adults:         params[:guest_details][:number_of_adults],
      children:       params[:guest_details][:number_of_children],
      infants:        params[:guest_details][:number_of_infants],
      status:         params[:status_type],
      currency:       params[:host_currency],
      payout_price:   params[:expected_payout_amount],
      security_price: params[:listing_security_price_accurate],
      total_price:    params[:total_paid_amount_accurate]
    }
  end

  def create_reservation_params
    mapped_params.merge(guest_attributes: guest_params)
  end

  def update_reservation_params
    mapped_params.merge(guest_attributes: guest_params.merge(id: @guest.id))
  end

  def found_guest_and_reservation?
    if @guest = Guest.find_by(email: params[:guest_email]) 
      if @reservation = @guest.reservations.find_by(code: params[:code])
        true
      end
    end
  end
end