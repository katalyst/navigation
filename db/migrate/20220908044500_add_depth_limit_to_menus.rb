# frozen_string_literal: true

class AddDepthLimitToMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_navigation_menus, :depth, :integer
  end
end
