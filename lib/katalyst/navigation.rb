# frozen_string_literal: true

require "katalyst/navigation/config"
require "katalyst/navigation/engine"
require "katalyst/navigation/version"

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
