# frozen_string_literal: true

module Katalyst
  module Navigation
    class ItemsController < Katalyst::Navigation.config.base_controller.constantize
      before_action :set_menu, only: %i[new create]
      before_action :set_item, except: %i[new create]

      attr_reader :menu, :item, :editor

      def new
        @item   = @menu.items.build(new_item_params)
        @editor = Katalyst::Navigation::EditorComponent.new(menu:, item:)

        render_editor
      end

      def edit
        render_editor
      end

      def create
        @item   = @menu.items.build(item_params)
        @editor = Katalyst::Navigation::EditorComponent.new(menu:, item:)

        if item.save
          render :update, locals: { editor:, item:, previous: @menu.items.build(type: item.type) }
        else
          render_editor status: :unprocessable_entity
        end
      end

      def update
        @item.attributes = item_params

        if @item.valid?
          previous = @item
          @item    = @item.dup.tap(&:save!)

          render locals: { editor:, item:, previous: }
        else
          render_editor status: :unprocessable_entity
        end
      end

      private

      def new_item_params
        { type: params[:type] || Link.name }
      end

      def item_params_type
        type = params.require(:item).fetch(:type, "")
        if Katalyst::Navigation.config.items.include?(type)
          type.safe_constantize
        else
          Item
        end
      end

      def item_params
        params.require(:item).permit(item_params_type.permitted_params)
      end

      def set_menu
        @menu   = Menu.find(params[:menu_id])
      end

      def set_item
        @item = Item.find(params[:id])
        @menu = @item.menu
        @editor = Katalyst::Navigation::EditorComponent.new(menu:, item:)
      end

      def render_editor(**)
        render(:edit, locals: { item_editor: editor.item_editor(item:) }, **)
      end
    end
  end
end
