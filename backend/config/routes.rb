# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      match '/players' => 'players#create', :via => :post

      resources :players
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
