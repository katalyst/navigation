# frozen_string_literal: true

FactoryBot.define do
  factory :katalyst_navigation_menu, aliases: [:navigation_menu], class: "Katalyst::Navigation::Menu" do
    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    after(:build) do |menu, _context|
      menu.items.each { |item| item.menu = menu }
    end

    after(:create) do |menu, _context|
      menu.items_attributes = menu.items.map.with_index { |item, index| { id: item.id, index: index, depth: 0 } }
      menu.publish!
    end
  end
end
