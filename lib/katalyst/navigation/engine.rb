# frozen_string_literal: true

require "katalyst/tables"
require "rails/engine"

module Katalyst
  module Navigation
    class Engine < ::Rails::Engine
      isolate_namespace Katalyst::Navigation
      config.eager_load_namespaces << Katalyst::Navigation

      initializer "katalyst-navigation.asset" do
        config.after_initialize do |app|
          if app.config.respond_to?(:assets)
            app.config.assets.precompile += %w(katalyst-navigation.js)
          end
        end
      end

      initializer "katalyst-navigation.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/builds")
        end
      end

      initializer "katalyst-navigation.factories", after: "factory_bot.set_factory_paths" do
        FactoryBot.definition_file_paths << Engine.root.join("spec/factories") if defined?(FactoryBot)
      end

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.factory_bot dir: "spec/factories"
      end
    end
  end
end
