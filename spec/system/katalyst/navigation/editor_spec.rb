# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/navigation/editor" do
  it "can add a link" do
    menu = create(:katalyst_navigation_menu)

    visit katalyst_navigation.menu_path(menu)

    click_on "Add item"
    click_on "Link"

    fill_in "Title", with: "Magic"
    fill_in "Url", with: "/magic"
    click_on "Done"

    expect(page).to have_css("li", text: "Magic")

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.published_items).to contain_exactly(having_attributes(title: "Magic", url: "/magic"))
  end

  it "can remove a link" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    expect(menu.draft_items).not_to be_empty

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-remove])") do |item|
      item.hover
      item.find("[data-icon='remove']").click
    end

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.published_items).to be_empty
  end

  it "can edit a link" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    expect(menu.draft_items).not_to be_empty

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-edit])") do |item|
      item.hover
      item.find("[data-icon='edit']").click
    end

    fill_in "Title", with: "Updated"
    click_on "Done"

    expect(page).to have_css("li", text: "Updated")

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.published_items).to contain_exactly(having_attributes(title: "Updated", url: link.url))
  end

  it "can re-order links", pending: "missing d&d" do
    links = build_list(:katalyst_navigation_link, 2)
    menu  = create(:katalyst_navigation_menu, items: links)

    expect(menu.items.map(&:url)).to eq([links.first.url, links.last.url])

    visit katalyst_navigation.menu_path(menu)

    # ensure that rules engine has run before dragging
    find("li[data-navigation-item]:not([data-deny-drag]):first-child")

    first = find("li[data-navigation-index='0']")
    last  = find("li[data-navigation-index='1']")
    first.drag_to(last)

    # check that items have been re-ordered (implicit wait)
    expect(page).to have_css("li[data-navigation-index='1'][data-navigation-item-id='#{links.first.id}']")

    # check that state has changed
    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.published_items.map(&:url)).to eq([links.last.url, links.first.url])
  end

  it "can change link depth" do
    heading = build(:katalyst_navigation_heading)
    link    = build(:katalyst_navigation_link)
    menu    = create(:katalyst_navigation_menu, items: [heading, link])

    expect(menu.draft_items.map(&:depth)).to eq([0, 0])

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-nest])") do |item|
      item.hover
      item.find("[data-icon='indent']").click
    end

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.published_items.map(&:depth)).to eq([0, 1])
  end

  context "with two non-layout siblings" do
    it "cannot change link depth" do
      links = build_list(:katalyst_navigation_link, 2)
      menu  = create(:katalyst_navigation_menu, items: links)

      expect(menu.draft_items.map(&:depth)).to eq([0, 0])

      visit katalyst_navigation.menu_path(menu)

      # ensure that link is not clickable
      expect(page).to have_css("li[data-navigation-item-id='#{links.last.id}'][data-deny-nest]")
    end
  end

  it "cannot change link depth when it would exceed limit" do
    links = build_list(:katalyst_navigation_link, 2)
    menu  = create(:katalyst_navigation_menu, items: links, depth: 1)

    expect(menu.draft_items.map(&:depth)).to eq([0, 0])

    visit katalyst_navigation.menu_path(menu)

    # ensure that link is not clickable
    expect(page).to have_css("li[data-navigation-item-id='#{links.last.id}'][data-deny-nest]")
  end

  it "can save without publishing" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-edit])") do |item|
      item.hover
      item.find("[data-icon='edit']").click
    end

    fill_in "Title", with: "Updated"
    click_on "Done"

    expect(page).to have_css("li", text: "Updated")

    click_on "Save"

    expect(page).to have_css("span", class: "status-text", text: "Draft", visible: :visible)

    menu.reload

    expect(menu.draft_items).to contain_exactly(having_attributes(title: "Updated", url: link.url))
  end

  it "can show errors on save" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-edit])") do |item|
      item.hover
      item.find("[data-icon='edit']").click
    end

    fill_in "Title", with: "Updated"
    click_on "Done"

    expect(page).to have_css("li", text: "Updated")
    menu.items.reload.destroy_all

    click_on "Save"

    expect(page).to have_text("Items are missing or invalid")
    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)
  end

  it "can revert a change" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-edit])") do |item|
      item.hover
      item.find("[data-icon='edit']").click
    end

    fill_in "Title", with: "Updated"
    click_on "Done"

    expect(page).to have_css("li", text: "Updated")

    click_on "Save"

    expect(page).to have_css("span", class: "status-text", text: "Draft", visible: :visible)

    click_on "Revert"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.draft_version).to eq(menu.published_version)
  end

  it "can publish a change" do
    link = build(:katalyst_navigation_link)
    menu = create(:katalyst_navigation_menu, items: [link])

    visit katalyst_navigation.menu_path(menu)

    within(".navigation--editor--item:not([data-deny-edit])") do |item|
      item.hover
      item.find("[data-icon='edit']").click
    end

    fill_in "Title", with: "Updated"
    click_on "Done"

    expect(page).to have_css("li", text: "Updated")

    click_on "Save"

    expect(page).to have_css("span", class: "status-text", text: "Draft", visible: :visible)

    click_on "Publish"

    expect(page).to have_css("span", class: "status-text", text: "Published", visible: :visible)

    menu.reload

    expect(menu.draft_version).to eq(menu.published_version)
    expect(menu.published_items).to contain_exactly(having_attributes(title: "Updated", url: link.url))
  end
end
