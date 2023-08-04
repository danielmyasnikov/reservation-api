# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reservations', type: :request do
  subject { post '/reservations', params: @params }

  def create_ar_guest
    @create_ar_guest ||= Guest.create!(
      first_name: 'Wayne',
      last_name: 'Woodbridge',
      phone: ['639123456789'],
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

      context "when guest exists" do
        before do
          @guest = create_ar_guest
          @reservation = create_ar_reservation
        end

        it 'creates another reservation for the same guest & reservation code' do
          @params[:email] = @guest.email
          @params[:reservation_code] = 'III567898764321'

          expect { subject }.to change { Reservation.count }.by(1)
          expect(response.code.to_i).to eq(201)
          expect(Guest.count).to eq(1) # NOTE: number of guests is 1 because, it was found by email
          expect(Reservation.count).to eq(2) # NOTE: number of reservation is 2 because a new was created
        end

        it 'updates reservation and guest' do
          @params[:start_date] = '2021-04-15'
          @params[:payout_price] = 3150.00
          @params[:total_price] = 3650.00
          @params[:guest][:first_name] = 'Will'
          @params[:children] = nil
          @params[:adults] = 1
          expect { subject }
            .to change { @guest.reload.first_name }.from('Wayne').to('Will')
            .and change { @reservation.reload.start_date.iso8601 }.from('2021-04-14').to('2021-04-15')
            .and change { @reservation.reload.payout_price }.from(4200.00).to(3150.00)
            .and change { @reservation.reload.children }.from(2).to(nil)
            .and change { @reservation.reload.adults }.from(2).to(1)
            .and change { @reservation.reload.total_price }.from(4700.00).to(3650.00)

          expect(response.code.to_i).to eq(201)
          expect(JSON.parse(response.body)['reservation'].keys.sort).to eq(["id", "reservations"].sort)
        end
      end

      context 'when malformed request' do
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
        expect(JSON.parse(response.body)['reservation'].keys.sort).to eq(["id", "reservations"].sort)
      end

      context 'when guest exists' do
        before do
          @guest = create_ar_guest
          @reservation = create_ar_reservation(code: 'XXX12345678')
        end

        it 'creates reservation and updates guest' do
          @params[:reservation][:code] = 'NEW_ONE_098765432'

          expect { subject }.to change { Reservation.count }.by(1)

          expect(response.code.to_i).to eq(201)
          expect(Guest.count).to eq(1) # NOTE: number of guests is 1 because, it was found by email
          expect(Reservation.count).to eq(2) # NOTE: number of reservation is 2 because a new was created
        end

        it 'updates reservation and guest' do
          @params[:reservation][:start_date] = '2021-04-15'
          @params[:reservation][:expected_payout_amount] = '3150.00'
          @params[:reservation][:total_paid_amount_accurate] = '3650.00'
          @params[:reservation][:guest_first_name] = 'Will'
          @params[:reservation][:guest_phone_numbers] = nil
          @params[:reservation][:guest_details][:number_of_adults] = nil
          @params[:reservation][:guest_details][:number_of_children] = 0
  
          expect { subject }
            .to change { @guest.reload.first_name }.from('Wayne').to('Will')
            .and change { @reservation.reload.start_date.iso8601 }.from('2021-04-14').to('2021-04-15')
            .and change { @reservation.reload.payout_price }.from(4200.00).to(3150.00)
            .and change { @reservation.reload.total_price }.from(4700.00).to(3650.00)
            .and change { @reservation.reload.children }.from(2).to(0)
            .and change { @reservation.reload.adults }.from(2).to(nil)
            .and change { @guest.reload.phone }.from(['639123456789']).to([])
  
          expect(response.code.to_i).to eq(201)
        end
      end

      context 'malformed request' do
        it 'responds with 400' do
          @params = { reservation: {} }
          expect(subject).to eq(400)
        end
      end
    end
  end
end
