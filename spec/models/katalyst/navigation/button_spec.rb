# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Button do
  subject(:button) { build(:navigation_button, menu: create(:navigation_menu)) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:http_method) }
  it { is_expected.to validate_inclusion_of(:http_method).in_array(described_class::HTTP_METHODS.values) }
end
