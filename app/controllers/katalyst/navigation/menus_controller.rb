# frozen_string_literal: true

module Katalyst
  module Navigation
    class MenusController < BaseController
      def index
        sort, menus = table_sort(Menu.all)

        render locals: { menus: menus, sort: sort }
      end

      def new
        render locals: { menu: Menu.new }
      end

      def create
        @menu = Menu.new(menu_params)

        if @menu.save
          redirect_to @menu
        else
          render :new, locals: { menu: @menu }, status: :unprocessable_entity
        end
      end

      def show
        menu = Menu.find(params[:id])

        render locals: { menu: menu }
      end

      def edit
        menu = Menu.find(params[:id])

        render locals: { menu: menu }
      end

      # PATCH /admins/navigation_menus/:slug
      def update
        menu = Menu.find(params[:id])

        menu.attributes = navigation_params

        unless menu.valid?
          return render :show, locals: { menu: menu }, status: :unprocessable_entity
        end

        case params[:commit]
        when "publish"
          menu.save!
          menu.publish!
        when "save"
          menu.save!
        when "revert"
          menu.revert!
        end
        redirect_to menu
      end

      def destroy
        menu = Menu.find(params[:id])

        menu.destroy!

        redirect_to action: :index, status: :see_other
      end

      private

      def menu_params
        params.require(:menu).permit(:title, :slug)
      end

      def navigation_params
        return {} if params[:menu].blank?

        params.require(:menu)
          .permit(:title, :slug, items_attributes: %i[id index depth])
      end
    end
  end
end
