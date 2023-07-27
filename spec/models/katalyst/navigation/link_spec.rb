# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Link do
  subject(:link) { build(:navigation_link, menu: create(:navigation_menu)) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to define_enum_for(:target).backed_by_column_of_type(:string).with_prefix(:target) }

  describe "#item_options" do
    subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :self) }

    it { is_expected.to be_target_self }
    it { is_expected.to have_attributes(target: "self") }
    it { is_expected.to have_attributes(item_options: {}) }

    context "with target set to top" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :top) }

      it { is_expected.to be_target_top }
      it { is_expected.to have_attributes(target: "top") }
      it { is_expected.to have_attributes(item_options: { target: "_top" }) }
    end

    context "with target set to blank" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :blank) }

      it { is_expected.to be_target_blank }
      it { is_expected.to have_attributes(target: "blank") }
      it { is_expected.to have_attributes(item_options: { target: "_blank" }) }
    end

    context "with target set to kpop" do
      subject(:link) { build(:navigation_link, menu: create(:navigation_menu), target: :kpop) }

      it { is_expected.to be_target_kpop }
      it { is_expected.to have_attributes(target: "kpop") }
      it { is_expected.to have_attributes(item_options: { data: { turbo_frame: "kpop" } }) }
    end
  end
end
