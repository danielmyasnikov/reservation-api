# frozen_string_literal: true

Rails.application.routes.draw do
  post 'reservations', to: 'reservations#create_or_update'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  match '*unmatched', to: 'application#route_not_found', via: :all
end
