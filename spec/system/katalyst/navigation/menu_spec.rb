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
    menu = create(:katalyst_navigation_menu, title: "Magic", slug: "magic")

    visit katalyst_navigation.menus_path

    expect(page).to have_text("Magic")

    visit katalyst_navigation.edit_menu_path(menu)

    fill_in "Title", with: "Not Magic"
    fill_in "Depth", with: "2"

    click_on "save"

    visit katalyst_navigation.menus_path
    expect(page).to have_text("Not Magic")

    expect(menu.reload).to have_attributes(title: "Not Magic", slug: "magic", depth: 2)
  end

  it "can delete a menu" do
    menu = create(:katalyst_navigation_menu, title: "Magic", slug: "magic")

    visit katalyst_navigation.menus_path

    expect(page).to have_text("Magic")

    visit katalyst_navigation.edit_menu_path(menu)

    accept_confirm do
      click_on "Delete"
    end

    expect(page).to have_no_text("Magic")
  end
end
