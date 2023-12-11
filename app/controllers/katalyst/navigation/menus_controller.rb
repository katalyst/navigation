# frozen_string_literal: true

module Katalyst
  module Navigation
    class MenusController < Katalyst::Navigation.config.base_controller.constantize
      include Katalyst::Tables::Backend

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
        menu   = Menu.find(params[:id])
        editor = Katalyst::Navigation::EditorComponent.new(menu:)

        render locals: { menu:, editor: }
      end

      def new
        menu   = Menu.new
        editor = Katalyst::Navigation::EditorComponent.new(menu:)

        render locals: { menu:, editor: }
      end

      def edit
        menu   = Menu.find(params[:id])
        editor = Katalyst::Navigation::EditorComponent.new(menu:)

        render locals: { menu:, editor: }
      end

      def create
        @menu = Menu.new(menu_params)
        editor = Katalyst::Navigation::EditorComponent.new(menu: @menu)

        if @menu.save
          @menu.build_draft_version
          @menu.save!
          redirect_to @menu, status: :see_other
        else
          render :new, locals: { menu: @menu, editor: }, status: :unprocessable_entity
        end
      end

      # PATCH /admins/navigation_menus/:slug
      def update
        menu = Menu.find(params[:id])
        editor = Katalyst::Navigation::EditorComponent.new(menu:)

        menu.attributes = menu_params

        unless menu.valid?
          return respond_to do |format|
            format.turbo_stream { render editor.errors, status: :unprocessable_entity }
          end
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
        redirect_to menu, status: :see_other
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
