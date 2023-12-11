# frozen_string_literal: true

module Katalyst
  module Navigation
    class MenusController < BaseController
      def index
        collection = Katalyst::Tables::Collection::Base.new(sorting: :title).with_params(params).apply(Menu.all)
        table      = Katalyst::Turbo::TableComponent.new(collection:,
                                                         id:         "index-table",
                                                         class:      "index-table",
                                                         caption:    true)

        respond_to do |format|
          format.turbo_stream { render(table) } if self_referred?
          format.html { render :index, locals: { table: } }
        end
      end

      def show
        menu = Menu.find(params[:id])

        render locals: { menu: }
      end

      def new
        render locals: { menu: Menu.new }
      end

      def edit
        menu = Menu.find(params[:id])

        render locals: { menu: }
      end

      def create
        @menu = Menu.new(menu_params)

        if @menu.save
          redirect_to @menu
        else
          render :new, locals: { menu: @menu }, status: :unprocessable_entity
        end
      end

      # PATCH /admins/navigation_menus/:slug
      def update
        menu = Menu.find(params[:id])

        menu.attributes = menu_params

        unless menu.valid?
          return render turbo_stream: helpers.navigation_editor_errors(menu:),
                        status:       :unprocessable_entity
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
        return {} if params[:menu].blank?

        params.require(:menu).permit(:title, :slug, :depth, items_attributes: %i[id index depth])
      end
    end
  end
end
