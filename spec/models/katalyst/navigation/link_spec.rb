# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Link do
  subject(:link) { build(:navigation_link, menu: create(:navigation_menu)) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to define_enum_for(:target).backed_by_column_of_type(:string).with_prefix(:target) }
  it { is_expected.to define_enum_for(:http_method).backed_by_column_of_type(:string).with_prefix(:http) }

  describe "#link_attributes" do
    subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :self) }

    it { is_expected.to be_target_self }
    it { is_expected.to have_attributes(target: "self") }
    it { is_expected.to have_attributes(link_attributes: {}) }

    context "with target set to top" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :top) }

      it { is_expected.to be_target_top }
      it { is_expected.to have_attributes(target: "top") }
      it { is_expected.to have_attributes(link_attributes: { target: "_top" }) }
    end

    context "with target set to blank" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :blank) }

      it { is_expected.to be_target_blank }
      it { is_expected.to have_attributes(target: "blank") }
      it { is_expected.to have_attributes(link_attributes: { target: "_blank" }) }
    end

    context "with target set to kpop" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :kpop) }

      it { is_expected.to be_target_kpop }
      it { is_expected.to have_attributes(target: "kpop") }
      it { is_expected.to have_attributes(link_attributes: { data: { turbo_frame: "kpop" } }) }
    end
  end
end
