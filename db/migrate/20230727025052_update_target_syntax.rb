# frozen_string_literal: true

# Ensures that all navigation items have a valid target and http_method.
class UpdateTargetSyntax < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/SkipsModelValidations
  def change
    Katalyst::Navigation::Item.where(http_method: nil).update_all(http_method: "get")
    Katalyst::Navigation::Item.where(target: nil).update_all(target: "self")
    Katalyst::Navigation::Item.where(target: "_blank").update_all(target: "blank")
    Katalyst::Navigation::Item.where(target: "_top").update_all(target: "top")
  end
  # rubocop:enable Rails/SkipsModelValidations
end
