class ReservationServiceOne
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
      @reservation = @guest.reservations.build(reservation_params)
    end
  end

  def call
    @reservation.save!
  end

  def guest_params
    params[:guest]
  end

  def mapped_params
    {
      code:           params[:reservation_code],
      start_date:     params[:start_date],
      end_date:       params[:end_date],
      nights:         params[:nights],
      guests:         params[:guests],
      adults:         params[:adults],
      children:       params[:children],
      infants:        params[:infants],
      status:         params[:status],
      currency:       params[:currency],
      payout_price:   params[:payout_price],
      security_price: params[:security_price],
      total_price:    params[:total_price],
    }
  end

  def reservation_params
    mapped_params.merge(guest_attributes: guest_params)
  end

  def update_reservation_params
    mapped_params.merge(guest_attributes: guest_params.merge(id: @guest.id))
  end

  def found_guest_and_reservation?
    if @guest = Guest.find_by(email: params[:guest][:email]) 
      if @reservation = @guest.reservations.find_by(code: params[:reservation_code])
        true
      end
    end
  end
end