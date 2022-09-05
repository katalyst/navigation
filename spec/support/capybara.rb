# frozen_string_literal: true

require "capybara/apparition"

Capybara.register_driver(:apparition) do |app|
  Capybara::Apparition::Driver.new(app, headless: true, debug: true)
end

RSpec.configure do |config|
  Capybara.default_driver = Capybara.javascript_driver = :apparition

  config.prepend_before(:each, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
