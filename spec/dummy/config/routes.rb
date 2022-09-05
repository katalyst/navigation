Rails.application.routes.draw do
  mount Katalyst::Navigation::Engine, at: "navigation"

  root to: redirect("/navigation")
end
