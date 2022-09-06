import Item from "utils/navigation/editor/item";

/**
 * @param nodes {NodeList}
 * @returns {Item[]}
 */
function createItemList(nodes) {
  return Array.from(nodes).map((node) => new Item(node));
}

export default class Menu {
  /**
   * @param node {Element} navigation editor list
   */
  constructor(node) {
    this.node = node;
  }

  /**
   * @return {Item[]} an ordered list of all items in the menu
   */
  get items() {
    return createItemList(
      this.node.querySelectorAll("[data-navigation-index]")
    );
  }

  /**
   *  @return {String} a serialized description of the structure of the menu
   */
  get state() {
    const inputs = this.node.querySelectorAll("li input[type=hidden]");
    return Array.from(inputs)
      .map((e) => e.value)
      .join("/");
  }

  /**
   * Set the index of items based on their current position.
   */
  reindex() {
    this.items.map((item, index) => (item.index = index));
  }

  /**
   * Resets the order of items to their defined index.
   * Useful after an aborted drag.
   */
  reset() {
    this.items.sort(Item.comparator).forEach((item) => {
      this.node.appendChild(item.node);
    });
  }
}
