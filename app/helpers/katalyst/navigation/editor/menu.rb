# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class Menu < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          submit->#{MENU_CONTROLLER}#reindex
          navigation:reindex->#{MENU_CONTROLLER}#reindex
          navigation:reset->#{MENU_CONTROLLER}#reset
        ACTIONS

        def build(options)
          form_with(model: menu, **default_options(id: menu_form_id, **options)) do |form|
            concat hidden_input
            concat(capture { yield form })
          end
        end

        private

        # Hidden input ensures that if the menu is empty then the controller
        # receives an empty array.
        def hidden_input
          tag.input(type: "hidden", name: "#{Item::ATTRIBUTES_SCOPE}[id]")
        end

        def default_options(options)
          add_option(options, :data, :controller, MENU_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)

          options
        end
      end
    end
  end
end
