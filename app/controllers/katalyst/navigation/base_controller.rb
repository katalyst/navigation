# frozen_string_literal: true

module Katalyst
  module Navigation
    class BaseController < ActionController::Base
      include Katalyst::Tables::Backend

      helper Katalyst::Navigation::EditorHelper
      helper Katalyst::Tables::Frontend
    end
  end
end
