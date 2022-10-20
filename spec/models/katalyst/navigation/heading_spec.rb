# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Navigation::Heading do
  subject(:link) { build :navigation_link, menu: create(:navigation_menu) }

  it { is_expected.to validate_presence_of(:title) }
end
