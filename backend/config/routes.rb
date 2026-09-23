# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      match '/players' => 'players#create', :via => :post

      resources :players do
        # POST /api/v1/players/results adds one result to a player by name
        collection { post :results }
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
