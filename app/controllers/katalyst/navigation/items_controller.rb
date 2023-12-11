# frozen_string_literal: true

module Katalyst
  module Navigation
    class ItemsController < BaseController
      before_action :set_menu
      before_action :set_item, except: %i[new create]

      def new
        render locals: { item: @menu.items.build(type: new_item_params) }
      end

      def edit
        render locals: { item: @item }
      end

      def create
        item = @menu.items.build(item_params)
        if item.save
          render :update, locals: { item:, previous: @menu.items.build(type: item.type) }
        else
          render :new, status: :unprocessable_entity, locals: { item: }
        end
      end

      def update
        @item.attributes = item_params

        if @item.valid?
          previous = @item
          @item    = @item.dup.tap(&:save!)
          render locals: { item: @item, previous: }
        else
          render :edit, status: :unprocessable_entity, locals: { item: @item }
        end
      end

      private

      def new_item_params
        params[:type] || Link.name
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
        @menu = Menu.find(params[:menu_id])
      end

      def set_item
        @item = @menu.items.find(params[:id])
      end
    end
  end
end
