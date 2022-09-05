export default class Item {
  /**
   * Sort items by their index.
   *
   * @param a {Item}
   * @param b {Item}
   * @returns {number}
   */
  static comparator(a, b) {
    return a.index - b.index;
  }

  /**
   * @param node {Element} li[data-navigation-index]
   */
  constructor(node) {
    this.node = node;
  }

  /**
   * @returns {String} id of the node's item (from data attributes)
   */
  get itemId() {
    return this.node.dataset[`navigationItemId`];
  }

  get #itemIdInput() {
    return this.node.querySelector(`input[name$="[id]"]`);
  }

  /**
   * @param itemId {String} id
   */
  set itemId(id) {
    if (this.itemId === id) return;

    this.node.dataset[`navigationItemId`] = `${id}`;
    this.#itemIdInput.value = `${id}`;
  }

  /**
   * @returns {number} logical nesting depth of node in menu
   */
  get depth() {
    return parseInt(this.node.dataset[`navigationDepth`]);
  }

  get #depthInput() {
    return this.node.querySelector(`input[name$="[depth]"]`);
  }

  /**
   * @param depth {number} depth >= 0
   */
  set depth(depth) {
    if (this.depth === depth) return;

    this.node.dataset[`navigationDepth`] = `${depth}`;
    this.#depthInput.value = `${depth}`;
  }

  /**
   * @returns {number} logical index of node in menu (pre-order traversal)
   */
  get index() {
    return parseInt(this.node.dataset[`navigationIndex`]);
  }

  get #indexInput() {
    return this.node.querySelector(`input[name$="[index]"]`);
  }

  /**
   * @param index {number} index >= 0
   */
  set index(index) {
    if (this.index === index) return;

    this.node.dataset[`navigationIndex`] = `${index}`;
    this.#indexInput.value = `${index}`;
  }

  /**
   * @returns {Item} nearest neighbour (index - 1)
   */
  get previousItem() {
    let sibling = this.node.previousElementSibling;
    if (sibling) return new Item(sibling);
  }

  /**
   * @returns {Item} nearest neighbour (index + 1)
   */
  get nextItem() {
    let sibling = this.node.nextElementSibling;
    if (sibling) return new Item(sibling);
  }

  /**
   * @returns {boolean} true if this item has any collapsed children
   */
  hasCollapsedDescendants() {
    let childrenList = this.#childrenListElement;
    return !!childrenList && childrenList.children.length > 0;
  }

  /**
   * @returns {boolean} true if this item has any expanded children
   */
  hasExpandedDescendants() {
    let sibling = this.nextItem;
    return !!sibling && sibling.depth > this.depth;
  }

  /**
   * Recursively traverse the node and its descendants.
   *
   * @callback {Item}
   */
  traverse(callback) {
    // capture descendants before traversal in case of side-effects
    // specifically, setting depth affects calculation
    const collapsed = this.#collapsedChildren;
    const expanded = this.#expandedDescendants;

    callback(this);
    collapsed.forEach((item) => item.traverse(callback));
    expanded.forEach((item) => item.traverse(callback));
  }

  /**
   * Collapses visible (logical) children into this element's hidden children
   * list, creating it if it doesn't already exist.
   */
  collapse() {
    let listElement = this.#childrenListElement;

    if (!listElement) listElement = createChildrenList(this.node);

    this.#expandedDescendants.forEach((child) =>
      listElement.appendChild(child.node)
    );
  }

  /**
   * Moves any collapsed children back into the parent menu.
   */
  expand() {
    if (!this.hasCollapsedDescendants()) return;

    Array.from(this.#childrenListElement.children)
      .reverse()
      .forEach((node) => {
        this.node.insertAdjacentElement("afterend", node);
      });
  }

  /**
   * Sets the state of a given rule on the target node.
   *
   * @param rule {String}
   * @param deny {boolean}
   */
  toggleRule(rule, deny = false) {
    if (this.node.dataset.hasOwnProperty(rule) && !deny)
      delete this.node.dataset[rule];
    if (!this.node.dataset.hasOwnProperty(rule) && deny)
      this.node.dataset[rule] = "";

    if (rule === "denyDrag") {
      if (!this.node.hasAttribute("draggable") && !deny) {
        this.node.setAttribute("draggable", "true");
      }
      if (this.node.hasAttribute("draggable") && deny) {
        this.node.removeAttribute("draggable");
      }
    }
  }

  /**
   * Detects turbo item changes by comparing the dataset id with the input
   */
  hasItemIdChanged() {
    return !(this.#itemIdInput.value === this.itemId);
  }

  /**
   * Updates inputs, in case they don't match the data values, e.g., when the
   * nested inputs have been hot-swapped by turbo with data from the server.
   *
   * Updates itemId from input as that is the canonical source.
   */
  updateAfterChange() {
    this.itemId = this.#itemIdInput.value;
    this.#indexInput.value = this.index;
    this.#depthInput.value = this.depth;
  }

  /**
   * Finds the dom container for storing collapsed (hidden) children, if present.
   *
   * @returns {Element} ol[data-navigation-children]
   */
  get #childrenListElement() {
    return this.node.querySelector(`:scope > [data-navigation-children]`);
  }

  get #expandedDescendants() {
    const descendants = [];

    let sibling = this.nextItem;
    while (sibling && sibling.depth > this.depth) {
      descendants.push(sibling);
      sibling = sibling.nextItem;
    }

    return descendants;
  }

  get #collapsedChildren() {
    if (!this.hasCollapsedDescendants()) return [];

    return Array.from(this.#childrenListElement.children).map(
      (node) => new Item(node)
    );
  }
}

/**
 * Finds or creates a dom container for storing collapsed (hidden) children.
 *
 * @param node {Element} li[data-navigation-index]
 * @returns {Element} ol[data-navigation-children]
 */
function createChildrenList(node) {
  const childrenList = document.createElement("ol");
  childrenList.setAttribute("class", "hidden");

  // if objectType is "rich-content" set richContentChildren as a data attribute
  childrenList.dataset[`navigationChildren`] = "";

  node.appendChild(childrenList);

  return childrenList;
}
