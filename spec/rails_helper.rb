# frozen_string_literal: true

require "spec_helper"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

Dir[Katalyst::Navigation::Engine.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ActiveSupport::Testing::TimeHelpers
end
