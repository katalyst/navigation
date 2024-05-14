# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class ErrorsComponent < BaseComponent
        def id
          dom_id(menu, :errors)
        end
      end
    end
  end
end
