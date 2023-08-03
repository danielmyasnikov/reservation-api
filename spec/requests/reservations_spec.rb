# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reservations', type: :request do
  subject { post '/reservations', params: @params }

  def create_ar_guest
    @create_ar_guest ||= Guest.create!(
      first_name: 'Wayne',
      last_name: 'Woodbridge',
      phone: '639123456789',
      email: 'wayne_woodbridge@bnb.com'
    )
  end

  def create_ar_reservation(opts = {})
    opts.reverse_merge!(
      guest_id: create_ar_guest.id,
      code: 'YYY12345678',
      start_date: '2021-04-14',
      end_date: '2021-04-18',
      nights: 4,
      guests: 4,
      adults: 2,
      children: 2,
      infants: 0,
      status: 'accepted',
      currency: 'AUD',
      payout_price: '4200.00',
      security_price: '500',
      total_price: '4700.00'
    )
    @create_ar_reservation ||= Reservation.create!(opts)
  end

  context 'when asked why not to use factory bots' do
    context 'the answer is it is slower than Active Record creation' do
      it 'shows that direct creation of AR object is by far (5_000) faster than factory bot' do
        # NOTE: Here is the message from the benchmark tool:
        #  "expected given block to perform faster than comparison block by exactly 2 times, but performed faster by 28103.52 times"
        # expect { create_ar_guest }.to perform_faster_than { create(:guest) }.exactly(2).times
        expect { create_ar_guest }.to perform_faster_than { create(:guest) }.at_least(5_000).times
      end
    end
  end

  describe 'POST /reservations' do
    context 'payload #1' do
      before do
        @params = {
          "reservation_code": 'YYY12345678',
          "start_date": '2021-04-14',
          "end_date": '2021-04-18',
          "nights": 4,
          "guests": 4,
          "adults": 2,
          "children": 2,
          "infants": 0,
          "status": 'accepted',
          "guest": {
            "first_name": 'Wayne',
            "last_name": 'Woodbridge',
            "phone": '639123456789',
            "email": 'wayne_woodbridge@bnb.com'
          },
          "currency": 'AUD',
          "payout_price": '4200.00',
          "security_price": '500',
          "total_price": '4700.00'
        }
      end

      it 'creates reservation and guest' do
        expect { subject }.to change { Guest.count }.by(1)
                          .and change { Reservation.count }.by(1)
        expect(response.code.to_i).to eq(201)
      end

      it 'updates reservation and guest' do
        # NOTE: setup models for the update
        guest = create_ar_guest
        reservation = create_ar_reservation

        @params[:start_date] = '2021-04-15'
        @params[:payout_price] = 3150.00
        @params[:total_price] = 3650.00
        @params[:guest][:first_name] = 'Will'

        expect { subject }
          .to change { guest.reload.first_name }.from('Wayne').to('Will')
          .and change { reservation.reload.start_date.iso8601 }.from('2021-04-14').to('2021-04-15')
          .and change { reservation.reload.payout_price }.from(4200.00).to(3150.00)
          .and change { reservation.reload.total_price }.from(4700.00).to(3650.00)

        expect(response.code.to_i).to eq(201)
      end

      xcontext 'when malformed request' do
        it 'responds with 400' do
          @params = { guest: nil, code: nil }
          expect(subject).to eq(400)
        end
      end
    end

    context 'payload #2' do
      before do
        @params = {
          "reservation": {
            "code": 'XXX12345678',
            "start_date": '2021-03-12',
            "end_date": '2021-03-16',
            "expected_payout_amount": '3800.00',
            "guest_details": {
              "localized_description": '4 guests',
              "number_of_adults": 2,
              "number_of_children": 2,
              "number_of_infants": 0
            },
            "guest_email": 'wayne_woodbridge@bnb.com',
            "guest_first_name": 'Wayne',
            "guest_last_name": 'Woodbridge',
            "guest_phone_numbers": %w[
              639123456789
              639123456789
            ],
            "listing_security_price_accurate": '500.00',
            "host_currency": 'AUD',
            "nights": 4,
            "number_of_guests": 4,
            "status_type": 'accepted',
            "total_paid_amount_accurate": '4300.00'
          }
        }
      end
      it 'creates reservation and guest' do
        expect { subject }.to change { Guest.count }.by(1)
                                                    .and change { Reservation.count }.by(1)
        expect(response.code.to_i).to eq(201)
      end

      it 'updates reservation and guest' do
        guest = create_ar_guest
        reservation = create_ar_reservation(code: 'XXX12345678')

        @params[:reservation][:start_date] = '2021-04-15'
        @params[:reservation][:expected_payout_amount] = '3150.00'
        @params[:reservation][:total_paid_amount_accurate] = '3650.00'
        @params[:reservation][:guest_first_name] = 'Will'

        expect { subject }
          .to change { guest.reload.first_name }.from('Wayne').to('Will')
          .and change { reservation.reload.start_date.iso8601 }.from('2021-04-14').to('2021-04-15')
          .and change { reservation.reload.payout_price }.from(4200.00).to(3150.00)
          .and change { reservation.reload.total_price }.from(4700.00).to(3650.00)

        expect(response.code.to_i).to eq(201)
      end

      xcontext 'malformed request' do
        it 'responds with 400' do
          @params = { reservation: nil }
          expect(subject).to eq(201)
        end
      end
    end
  end
end
