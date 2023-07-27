# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Button do
  subject(:button) { build(:navigation_button, menu: create(:navigation_menu)) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:http_method) }
  it { is_expected.to define_enum_for(:http_method).backed_by_column_of_type(:string).with_prefix(:http) }

  describe "#item_options" do
    subject(:button) { build(:navigation_button, menu: create(:navigation_menu), http_method: :get) }

    it { is_expected.to be_http_get }
    it { is_expected.to have_attributes(http_method: "get") }
    it { is_expected.to have_attributes(item_options: {}) }

    context "with method set to post" do
      subject(:button) { build(:navigation_button, menu: create(:navigation_menu), http_method: :post) }

      it { is_expected.to be_http_post }
      it { is_expected.to have_attributes(http_method: "post") }
      it { is_expected.to have_attributes(item_options: { data: { turbo_method: "post" } }) }
    end

    context "with target blank and post (invalid)" do
      subject(:button) { build(:navigation_button, menu: create(:navigation_menu), target: :blank, http_method: :post) }

      it { is_expected.to be_http_post }
      it { is_expected.to have_attributes(http_method: "post") }
      it { is_expected.to have_attributes(item_options: { target: "_blank" }) }
    end

    context "with target top and post (valid)" do
      subject(:button) { build(:navigation_button, menu: create(:navigation_menu), target: :top, http_method: :post) }

      it { is_expected.to be_http_post }
      it { is_expected.to have_attributes(http_method: "post") }
      it { is_expected.to have_attributes(item_options: { target: "_top", data: { turbo_method: "post" } }) }
    end
  end
end
