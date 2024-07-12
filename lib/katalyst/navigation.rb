# frozen_string_literal: true

require "active_support"

module Katalyst
  module Navigation # :nodoc:
    extend ActiveSupport::Autoload
    extend self

    autoload :Config

    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end

require "katalyst/navigation/engine"
