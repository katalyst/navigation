export default class RulesEngine {
  static rules = [
    "denyDeNest",
    "denyNest",
    "denyCollapse",
    "denyExpand",
    "denyRemove",
    "denyDrag",
    "denyEdit",
    "invalidDepth",
  ];

  /**
   * Apply rules to the given item by computing a ruleset then merging it
   * with the item's current state.
   *
   * @param {Item} item
   */
  update(item) {
    this.rules = {};

    this.firstItemDepthZero(item);
    this.depthMustBeSet(item);
    this.parentsCannotDeNest(item);
    this.rootsCannotDeNest(item);
    this.nestingNeedsParent(item);
    this.leavesCannotCollapse(item);
    this.needHiddenItemsToExpand(item);
    this.parentsCannotBeDeleted(item);
    this.parentsCannotBeDragged(item);
    this.itemCannotHaveInvalidDepth(item);

    RulesEngine.rules.forEach((rule) => {
      item.toggleRule(rule, !!this.rules[rule]);
    });
  }

  /**
   * First item can't have a parent, so its depth should always be 0
   */
  firstItemDepthZero(item) {
    if (item.index === 0) {
      item.depth = 0;
    }
  }

  /**
   * Every item should have a non-negative depth set.
   *
   * @param {Item} item
   */
  depthMustBeSet(item) {
    if (isNaN(item.depth) || item.depth < 0) {
      item.depth = 0;
    }
  }

  /**
   * De-nesting an item would create a gap of 2 between itself and its children
   *
   * @param {Item} item
   */
  parentsCannotDeNest(item) {
    if (item.hasExpandedDescendants()) this.#deny("denyDeNest");
  }

  /**
   * Item depth can't go below 0.
   *
   * @param {Item} item
   */
  rootsCannotDeNest(item) {
    if (item.depth === 0) this.#deny("denyDeNest");
  }

  /**
   * If an item doesn't have children it can't be collapsed.
   *
   * @param {Item} item
   */
  leavesCannotCollapse(item) {
    if (!item.hasExpandedDescendants()) this.#deny("denyCollapse");
  }

  /**
   * If an item doesn't have any hidden descendants then it can't be expanded.
   *
   * @param {Item} item
   */
  needHiddenItemsToExpand(item) {
    if (!item.hasCollapsedDescendants()) this.#deny("denyExpand");
  }

  /**
   * An item can't be nested (indented) if it doesn't have a valid parent.
   *
   * @param {Item} item
   */
  nestingNeedsParent(item) {
    const previous = item.previousItem;
    if (!previous || previous.depth < item.depth) this.#deny("denyNest");
  }

  /**
   * An item can't be deleted if it has visible children.
   *
   * @param {Item} item
   */
  parentsCannotBeDeleted(item) {
    if (item.hasExpandedDescendants()) this.#deny("denyRemove");
  }

  /**
   * Items cannot be dragged if they have visible children.
   *
   * @param {Item} item
   */
  parentsCannotBeDragged(item) {
    if (item.hasExpandedDescendants()) this.#deny("denyDrag");
  }

  /**
   * Depth must increase stepwise.
   *
   * @param {Item} item
   */
  itemCannotHaveInvalidDepth(item) {
    const previous = item.previousItem;
    if (previous && previous.depth < item.depth - 1) this.#deny("invalidDepth");
  }

  /**
   * Record a deny.
   *
   * @param rule {String}
   */
  #deny(rule) {
    this.rules[rule] = true;
  }
}
