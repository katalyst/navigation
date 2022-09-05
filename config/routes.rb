# frozen_string_literal: true

Katalyst::Navigation::Engine.routes.draw do
  resources :menus do
    resources :items, only: %i[new create edit update]
  end

  root to: redirect("menus")
end
