class AddFieldsToKatalystNavigationItems < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_navigation_items, :caption, :string
    add_column :katalyst_navigation_items, :alt_text, :string
  end
end
