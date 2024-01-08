export default class RulesEngine {
  static rules = [
    "denyDeNest",
    "denyNest",
    "denyCollapse",
    "denyExpand",
    "denyRemove",
    "denyDrag",
    "denyEdit",
  ];

  constructor(maxDepth = null, debug = false) {
    this.maxDepth = maxDepth;
    if (debug) {
      this.debug = (...args) => console.log(...args);
    } else {
      this.debug = () => {};
    }
  }

  /**
   * Enforce structural rules to ensure that the given item is currently in a
   * valid state.
   *
   * @param {Item} item
   */
  normalize(item) {
    // structural rules enforce a valid tree structure
    this.firstItemDepthZero(item);
    this.depthMustBeSet(item);
    this.itemCannotHaveInvalidDepth(item);
    this.itemCannotExceedDepthLimit(item);
    this.parentMustBeLayout(item);
    this.parentCannotHaveExpandedAndCollapsedChildren(item);
  }

  /**
   * Apply rules to the given item to determine what operations are permitted.
   *
   * @param {Item} item
   */
  update(item) {
    this.rules = {};

    // behavioural rules define what the user is allowed to do
    this.parentsCannotDeNest(item);
    this.rootsCannotDeNest(item);
    this.nestingNeedsParent(item);
    this.nestingCannotExceedMaxDepth(item);
    this.leavesCannotCollapse(item);
    this.needHiddenItemsToExpand(item);
    this.parentsCannotBeDeleted(item);
    this.parentsCannotBeDragged(item);

    RulesEngine.rules.forEach((rule) => {
      item.toggleRule(rule, !!this.rules[rule]);
    });
  }

  /**
   * First item can't have a parent, so its depth should always be 0
   */
  firstItemDepthZero(item) {
    if (item.index === 0 && item.depth !== 0) {
      this.debug(`enforce depth on item ${item.index}: ${item.depth} => 0`);

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
      this.debug(`unset depth on item ${item.index}: => 0`);

      item.depth = 0;
    }
  }

  /**
   * Depth must increase stepwise.
   *
   * @param {Item} item
   */
  itemCannotHaveInvalidDepth(item) {
    const previous = item.previousItem;
    if (previous && previous.depth < item.depth - 1) {
      this.debug(
        `invalid depth on item ${item.index}: ${item.depth} => ${
          previous.depth + 1
        }`,
      );

      item.depth = previous.depth + 1;
    }
  }

  /**
   * Depth must not exceed menu's depth limit.
   *
   * @param {Item} item
   */
  itemCannotExceedDepthLimit(item) {
    if (this.maxDepth > 0 && this.maxDepth <= item.depth) {
      // Note: this change can cause an issue where the previous item is treated
      // like a parent even though it no longer has children. This is because
      // items are processed in order. This issue does not seem worth solving
      // as it only occurs if the max depth is altered. The issue can be worked
      // around by saving the menu.
      item.depth = this.maxDepth - 1;
    }
  }

  /**
   * Parent item, if any, must be a layout.
   *
   * @param {Item} item
   */
  parentMustBeLayout(item) {
    // if we're the first child, make sure our parent is a layout
    // if we're a sibling, we know the previous item is valid so we must be too
    const previous = item.previousItem;
    if (previous && previous.depth < item.depth && !previous.isLayout) {
      this.debug(
        `invalid parent for item ${item.index}: ${item.depth} => ${previous.depth}`,
      );

      item.depth = previous.depth;
    }
  }

  /**
   * If a parent has expanded and collapsed children, expand.
   *
   * @param {Item} item
   */
  parentCannotHaveExpandedAndCollapsedChildren(item) {
    if (item.hasCollapsedDescendants() && item.hasExpandedDescendants()) {
      this.debug(`expanding collapsed children of item ${item.index}`);

      item.expand();
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
    // no previous, so cannot nest
    if (!previous) this.#deny("denyNest");
    // previous is too shallow, nesting would increase depth too much
    else if (previous.depth < item.depth) this.#deny("denyNest");
    // new parent is not a layout
    else if (previous.depth === item.depth && !previous.isLayout)
      this.#deny("denyNest");
  }

  /**
   * An item can't be nested (indented) if doing so would exceed the max depth.
   *
   * @param {Item} item
   */
  nestingCannotExceedMaxDepth(item) {
    if (this.maxDepth > 0 && this.maxDepth <= item.depth + 1) {
      this.#deny("denyNest");
    }
  }

  /**
   * An item can't be deleted if it has visible children.
   *
   * @param {Item} item
   */
  parentsCannotBeDeleted(item) {
    if (!item.itemId || item.hasExpandedDescendants()) this.#deny("denyRemove");
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
   * Record a deny.
   *
   * @param rule {String}
   */
  #deny(rule) {
    this.rules[rule] = true;
  }
}
