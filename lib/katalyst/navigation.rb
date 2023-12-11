# frozen_string_literal: true

require "active_support"
require "katalyst/html_attributes"
require "katalyst/kpop"
require "katalyst/tables"
require "view_component"

require "katalyst/navigation/config"
require "katalyst/navigation/engine"

module Katalyst
  module Navigation # :nodoc:
    extend self

    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
