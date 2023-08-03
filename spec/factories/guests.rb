# frozen_string_literal: true

FactoryBot.define do
  factory :guest do
    first_name { 'John' }
    last_name  { 'Doe' }
    phone { ['6123456789'] }
    email { 'dan@mail.com' }
  end
end
