# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::ItemsController do
  subject { action && response }

  let(:menu) { create(:katalyst_navigation_menu) }

  describe "GET /admin/navigations/:slug/links/new" do
    let(:action) { get katalyst_navigation.new_menu_item_path(menu) }

    it { is_expected.to be_successful }
  end

  describe "POST /admin/navigations/:slug/links/" do
    let(:action) do
      post katalyst_navigation.menu_items_path(menu),
           params: { item: link_params },
           as:     :turbo_stream
    end
    let(:link_params) { attributes_for(:katalyst_navigation_link).merge(type: Katalyst::Navigation::Link.name) }

    it { is_expected.to be_successful }

    it { expect { action }.to change(Katalyst::Navigation::Link, :count).by(1) }

    context "with invalid params" do
      let(:link_params) { { title: "" }.merge(type: Katalyst::Navigation::Link.name) }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Katalyst::Navigation::Link, :count) }
    end
  end

  describe "GET /admin/navigations/:slug/links/:id/edit" do
    let(:action) { get katalyst_navigation.edit_menu_item_path(menu, link) }
    let(:link) { create(:katalyst_navigation_link, menu: menu) }

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/navigations/:slug/links/:id" do
    let(:action) do
      patch katalyst_navigation.menu_item_path(menu, link),
            params: { item: link_params },
            as:     :turbo_stream
    end
    let(:title) { Faker::Beer.name }
    let!(:link) { create(:katalyst_navigation_link, menu: menu, title: title) }
    let(:link_params) { { title: "A new level" } }

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(link, :title) }
    it { expect { action }.to change(Katalyst::Navigation::Link, :count).by(1) }

    it "sets title in the new link version" do
      action
      expect(Katalyst::Navigation::Link.last.title).to eq("A new level")
    end

    context "with invalid params" do
      let(:link_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
    end
  end
end
