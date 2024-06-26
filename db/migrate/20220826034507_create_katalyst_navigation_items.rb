# frozen_string_literal: true

class CreateKatalystNavigationItems < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_navigation_items do |t|
      t.belongs_to :menu, foreign_key: { to_table: :katalyst_navigation_menus }, null: false

      t.string :type
      t.string :title
      t.string :url
      t.string :http_method
      t.string :target
      t.boolean :visible, default: true, null: false

      t.timestamps
    end
  end
end
