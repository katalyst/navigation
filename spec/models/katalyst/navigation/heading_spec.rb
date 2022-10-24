# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Heading do
  subject(:heading) { build :navigation_heading, menu: create(:navigation_menu) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.not_to validate_presence_of(:url) }
end
