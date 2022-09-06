# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/navigation/menu" do
  it "can add a menu" do
    visit katalyst_navigation.menus_path

    expect(page).to have_text("Title")

    click_on "Add"

    fill_in "Title", with: "Magic"
    fill_in "Slug", with: "magic"

    click_on "Create Menu"

    # Menu show page
    expect(page).to have_text "Publish"
  end

  it "can edit a menu" do
    menu = create :katalyst_navigation_menu, title: "Magic", slug: "magic"

    visit katalyst_navigation.menus_path

    expect(page).to have_text("Magic")

    visit katalyst_navigation.edit_menu_path(menu)

    fill_in "Title", with: "Not Magic"

    click_on "save"

    visit katalyst_navigation.menus_path
    expect(page).to have_text("Not Magic")
  end

  it "can delete a menu" do
    menu = create :katalyst_navigation_menu, title: "Magic", slug: "magic"

    visit katalyst_navigation.menus_path

    expect(page).to have_text("Magic")

    visit katalyst_navigation.edit_menu_path(menu)

    click_on "Delete"

    expect(page).not_to have_text("Magic")
  end
end
