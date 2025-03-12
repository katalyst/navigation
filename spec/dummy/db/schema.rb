# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2023_07_27_025052) do
  create_table "katalyst_navigation_items", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.string "type"
    t.string "title"
    t.string "url"
    t.string "http_method"
    t.string "target"
    t.boolean "visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_katalyst_navigation_items_on_menu_id"
  end

  create_table "katalyst_navigation_menu_versions", force: :cascade do |t|
    t.integer "parent_id", null: false
    t.json "nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_katalyst_navigation_menu_versions_on_parent_id"
  end

  create_table "katalyst_navigation_menus", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.integer "published_version_id"
    t.integer "draft_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "depth"
    t.index ["draft_version_id"], name: "index_katalyst_navigation_menus_on_draft_version_id"
    t.index ["published_version_id"], name: "index_katalyst_navigation_menus_on_published_version_id"
    t.index ["slug"], name: "index_katalyst_navigation_menus_on_slug"
  end

  add_foreign_key "katalyst_navigation_items", "katalyst_navigation_menus", column: "menu_id"
  add_foreign_key "katalyst_navigation_menu_versions", "katalyst_navigation_menus", column: "parent_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "draft_version_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "published_version_id"
end
