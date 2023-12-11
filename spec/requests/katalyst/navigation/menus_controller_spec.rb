# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::MenusController do
  subject { action && response }

  shared_context "with draft" do
    before do
      link = create(:navigation_link, menu:)
      menu.update!(items_attributes: [{ id: link.id, depth: 0, index: 0 }])
    end
  end

  describe "GET /navigation/menus" do
    let(:action) { get katalyst_navigation.menus_path }

    it { is_expected.to be_successful }
  end

  describe "GET /navigation/menus/new" do
    let(:action) { get katalyst_navigation.new_menu_path }

    it { is_expected.to be_successful }
  end

  describe "POST /navigation/menus" do
    let(:action) { post katalyst_navigation.menus_path, params: { menu: menu_params } }
    let(:menu_params) { attributes_for(:katalyst_navigation_menu, depth: 1) }

    it { is_expected.to redirect_to(katalyst_navigation.menu_path(assigns(:menu))) }

    it { expect { action }.to change(Katalyst::Navigation::Menu, :count).by(1) }

    it "sets attributes correctly" do
      action
      expect(assigns(:menu)).to have_attributes(menu_params)
    end

    context "with invalid params" do
      let(:menu_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Katalyst::Navigation::Menu, :count) }
    end
  end

  describe "GET /navigation/menus/:id" do
    let(:action) { get katalyst_navigation.menu_path(menu) }
    let(:menu) { create(:katalyst_navigation_menu) }

    it { is_expected.to be_successful }
  end

  describe "GET /navigation/menus/:id/edit" do
    let(:action) { get katalyst_navigation.edit_menu_path(menu) }
    let(:menu) { create(:katalyst_navigation_menu) }

    it { is_expected.to be_successful }
  end

  describe "PATCH /navigation/menus/:id" do
    let(:action) { patch katalyst_navigation.menu_path(menu), params: { menu: menu_params, commit: } }
    let(:menu) { create(:katalyst_navigation_menu) }
    let(:menu_params) do
      {
        items_attributes: [
          { id: create(:navigation_link, menu:).id, depth: 0, index: 0 },
          { id: create(:navigation_link, menu:).id, depth: 1, index: 1 },
        ],
      }
    end
    let(:commit) { "discard" }

    it { is_expected.to redirect_to(katalyst_navigation.menu_path(menu)) }

    context "with title/slug on save" do
      let(:menu_params) { { title: "updated" } }
      let(:commit) { "save" }

      it { expect { action }.to change { menu.reload.title }.from(menu.title).to("updated") }
      it { expect { action }.not_to change(menu, :state) }
    end

    context "when save" do
      let(:commit) { "save" }

      it { expect { action }.to change { menu.reload.state }.from(:published).to(:draft) }
    end

    context "when publish" do
      let(:commit) { "publish" }

      include_context "with draft"

      it { expect { action }.to change { menu.reload.state }.from(:draft).to(:published) }
    end

    context "when revert" do
      let(:commit) { "revert" }

      include_context "with draft"

      it { expect { action }.to change { menu.reload.state }.from(:draft).to(:published) }
    end
  end

  describe "DELETE /navigation/menus/:id" do
    let(:action) { delete katalyst_navigation.menu_path(menu) }
    let!(:menu) { create(:katalyst_navigation_menu) }

    it { is_expected.to have_http_status(:see_other) }
    it { is_expected.to redirect_to(katalyst_navigation.menus_path) }
    it { expect { action }.to change(Katalyst::Navigation::Menu, :count).to(0) }
  end
end
