import MenuController from "./editor/menu_controller";
import ItemController from "./editor/item_controller";
import ListController from "./editor/list_controller";
import NewItemController from "./editor/new_item_controller";
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
    identifier: "navigation--editor--new-item",
    controllerConstructor: NewItemController,
  },
  {
    identifier: "navigation--editor--status-bar",
    controllerConstructor: StatusBarController,
  },
];

export { Definitions as default };
