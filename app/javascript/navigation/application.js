import MenuController from "./editor/menu_controller";
import ItemController from "./editor/item_controller";
import ListController from "./editor/list_controller";
import NewItemsController from "./editor/new_items_controller";
import StatusBarController from "./editor/status_bar_controller";

const Definitions = [
  {
    identifier: "navigation--editor--menu",
    controllerConstructor: MenuController,
  },
  {
    identifier: "navigation--editor--item",
    controllerConstructor: ItemController,
  },
  {
    identifier: "navigation--editor--list",
    controllerConstructor: ListController,
  },
  {
    identifier: "navigation--editor--new-items",
    controllerConstructor: NewItemsController,
  },
  {
    identifier: "navigation--editor--status-bar",
    controllerConstructor: StatusBarController,
  },
];

export { Definitions as default };
