require 'rails_helper'

RSpec.describe "Reservations", type: :request do
  subject { post '/reservations', params: @params }

  describe "POST /reservations" do
    context 'payload #1' do

      before do
        @params = {
          "reservation_code": "YYY12345678",
          "start_date": "2021-04-14",
          "end_date": "2021-04-18",
          "nights": 4,
          "guests": 4,
          "adults": 2,
          "children": 2,
          "infants": 0,
          "status": "accepted",
          "guest": {
            "first_name": "Wayne",
            "last_name": "Woodbridge",
            "phone": "639123456789",
            "email": "wayne_woodbridge@bnb.com"
          },
          "currency": "AUD",
          "payout_price": "4200.00",
          "security_price": "500",
          "total_price": "4700.00"
        }
      end

      it "creates reservation and guest" do
        expect(Reservation.count).to eq(0)
        expect(Guest.count).to eq(0)
        expect(subject).to eq(201)
        expect(Reservation.count).to eq(1)
        expect(Guest.count).to eq(1)
      end

      it "updates reservation and guest" do
        # NOTE: setup models for the update
        g = Guest.create!(
          "first_name": "Wayne",
          "last_name": "Woodbridge",
          "phone": "639123456789",
          "email": "wayne_woodbridge@bnb.com"
        )
        r = Reservation.create!(
          guest_id: g.id,
          "code": "YYY12345678",
          "start_date": "2021-04-14",
          "end_date": "2021-04-18",
          "nights": 4,
          "guests": 4,
          "adults": 2,
          "children": 2,
          "infants": 0,
          "status": "accepted",
          "currency": "AUD",
          "payout_price": "4200.00",
          "security_price": "500",
          "total_price": "4700.00"
        )
        @params[:start_date] = "2021-04-15"  
        @params[:payout_price] = 3150.00
        @params[:total_price] = 3650.00
        @params[:guest][:first_name] = "Will"
          
        expect(subject).to eq(201)
        expect(Guest.count).to eq(1)
        expect(Reservation.count).to eq(1)

        expect(Guest.first.first_name).to eq('Will')
        expect(Reservation.first.start_date.iso8601).to eq("2021-04-15")
        expect(Reservation.first.payout_price).to eq(3150.00)
        expect(Reservation.first.total_price).to eq(3650.00)
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
            "code": "XXX12345678",
            "start_date": "2021-03-12",
            "end_date": "2021-03-16",
            "expected_payout_amount": "3800.00",
            "guest_details": {
              "localized_description": "4 guests",
              "number_of_adults": 2,
              "number_of_children": 2,
              "number_of_infants": 0
            },
            "guest_email": "wayne_woodbridge@bnb.com",
            "guest_first_name": "Wayne",
            "guest_last_name": "Woodbridge",
            "guest_phone_numbers": [
              "639123456789",
              "639123456789"
            ],
            "listing_security_price_accurate": "500.00",
            "host_currency": "AUD",
            "nights": 4,
            "number_of_guests": 4,
            "status_type": "accepted",
            "total_paid_amount_accurate": "4300.00"
          }
        }
      end
      it "creates reservation and guest" do
        expect(subject).to eq(201)
      end

      it "updates reservation and guest" do
        g = Guest.create!(
          "first_name": "Wayne",
          "last_name": "Woodbridge",
          "phone": "639123456789",
          "email": "wayne_woodbridge@bnb.com"
        )
        r = Reservation.create!(
          guest_id: g.id,
          "code": "XXX12345678",
          "start_date": "2021-04-14",
          "end_date": "2021-04-18",
          "nights": 4,
          "guests": 4,
          "adults": 2,
          "children": 2,
          "infants": 0,
          "status": "accepted",
          "currency": "AUD",
          "payout_price": "4200.00",
          "security_price": "500",
          "total_price": "4700.00"
        )

        @params[:reservation][:start_date] = "2021-04-15"
        @params[:reservation][:expected_payout_amount] = "3150.00"
        @params[:reservation][:total_paid_amount_accurate] = "3650.00"
        @params[:reservation][:guest_first_name] = "Will"

        expect(subject).to eq(201)

        expect(Guest.count).to eq(1)
        expect(Reservation.count).to eq(1)

        expect(Guest.first.first_name).to eq('Will')
        expect(Reservation.first.start_date.iso8601).to eq("2021-04-15")
        expect(Reservation.first.payout_price).to eq(3150.00)
        expect(Reservation.first.total_price).to eq(3650.00)

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
