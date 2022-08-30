# frozen_string_literal: true

FactoryBot.define do
  factory :katalyst_navigation_link, aliases: [:navigation_link], class: "Katalyst::Navigation::Link" do
    title { Faker::Beer.hop }
    url { Faker::Internet.unique.url }
  end

  factory :katalyst_navigation_button, aliases: [:navigation_button], class: "Katalyst::Navigation::Button" do
    title { Faker::Beer.hop }
    url { Faker::Internet.unique.url }
    http_method { Katalyst::Navigation::Button::HTTP_METHODS.keys.sample }
  end
end
