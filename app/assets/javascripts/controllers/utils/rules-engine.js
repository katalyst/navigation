function getCamelCase(attr) {
  return attr.replace(/-./g, (m) => m[1].toUpperCase());
}

function childrenList(node, objectType) {
  let childrenList = node.querySelector(`:scope > [data-${objectType}-children]`);

  if (!childrenList) {
    childrenList = document.createElement("ol");
    childrenList.setAttribute("class", "hidden");

    // if objectType is "rich-content" set richContentChildren as a data attribute
    childrenList.dataset[`${getCamelCase(objectType)}Children`] = "";

    node.appendChild(childrenList);
  }

  return childrenList;
}

function hasVisibleDescendants(node, objectType) {
  let sibling = node.nextElementSibling;
  return sibling && depth(sibling, objectType) > depth(node, objectType);
}

function hasHiddenDescendants(node, objectType) {
  return childrenList(node, objectType).children.length > 0;
}

function index(node, objectType) {
  return parseInt(node.dataset[`${getCamelCase(objectType)}Index`]);
}

function setIndex(node, value, objectType) {
  if (index(node, objectType) !== value) {
    node.dataset[`${getCamelCase(objectType)}Index`] = value;
    node.querySelector(`[data-${objectType}-index-input]`).value = value;
  }
}

function depth(node, objectType) {
  return parseInt(node.dataset[`${getCamelCase(objectType)}Depth`]);
}

function setDepth(node, value, objectType) {
  if (depth(node, objectType) !== value) {
    node.dataset[`${getCamelCase(objectType)}Depth`] = value;
    node.querySelector(`[data-${objectType}-depth-input]`).value = value;
  }
}

class RulesEngine {
  constructor(objectType) {
    this.properties = [
      "denyDeNest",
      "denyNest",
      "denyCollapse",
      "denyExpand",
      "denyDelete",
      "denyDrag",
      "denyEdit",
      "invalidDepth"
    ];
    this._rules = {};
    this.objectType = objectType;
  }

  rules(node) {
    let rules = this._rules[index(node, this.objectType)];
    if (!rules) {
      rules = {};
      this._rules[index(node, this.objectType)] = rules;
    }
    return rules;
  }

  deny(node, property) {
    this.rules(node)[property] = true;
  }

  isDeny(node, property) {
    return this.rules(node)[property];
  }

  /**
   * @param node {Element}
   */
  unifyNode(node) {
    this.properties.forEach(p => {
      const deny = this.isDeny(node, p);
      switch (p) {
        case "denyDrag":
          if (node.dataset.hasOwnProperty(p) && !deny) {
            delete node.dataset[p];
            node.setAttribute("draggable", "true");
          }
          if (!node.dataset.hasOwnProperty(p) && deny) {
            node.dataset[p] = "";
            node.removeAttribute("draggable");
          }
          break;
        default:
          if (node.dataset.hasOwnProperty(p) && !deny) delete node.dataset[p];
          if (!node.dataset.hasOwnProperty(p) && deny) node.dataset[p] = "";
          break;
      }
    })
  }

  update(nodes) {
    this.firstItemDepthZero(nodes);

    nodes.forEach(node => {
      this.depthMustBeSet(node);
      this.parentsCannotDeNest(node);
      this.rootsCannotDeNest(node);
      this.nestingNeedsParent(node);
      this.leavesCannotCollapse(node);
      this.needHiddenItemsToExpand(node);
      this.parentsCannotBeDeleted(node);
      this.parentsCannotBeDragged(node);
      this.deletedItemsCannotBeEdited(node);

      this.itemCannotHaveInvalidDepth(node);
    })

    nodes.forEach(node => this.unifyNode(node));
  }

  /**
   * First item can't have a parent, so its depth should always be 0
   */
  firstItemDepthZero(nodes) {
    if (nodes.length > 0) {
      setDepth(nodes[0], 0, this.objectType);
    }
  }

  /**
   * Every item should have a non-negative depth set.
   */
  depthMustBeSet(node) {
    if (isNaN(depth(node, this.objectType)) || depth(node, this.objectType) < 0) {
      setDepth(node, 0, this.objectType);
    }
  }

  /**
   * De-nesting an item would create a gap of 2 between itself and its children
   */
  parentsCannotDeNest(node) {
    if (hasVisibleDescendants(node, this.objectType)) this.deny(node, "denyDeNest");
  }

  /**
   * Item depth can't go below 0
   */
  rootsCannotDeNest(node) {
    if (depth(node, this.objectType) === 0) this.deny(node, "denyDeNest");
  }

  leavesCannotCollapse(node) {
    if (!hasVisibleDescendants(node, this.objectType)) this.deny(node, "denyCollapse");
  }

  needHiddenItemsToExpand(node) {
    if (!hasHiddenDescendants(node, this.objectType)) this.deny(node, "denyExpand");
  }

  nestingNeedsParent(node) {
    const previous = node.previousElementSibling;
    if (!previous || depth(previous, this.objectType) < depth(node, this.objectType)) this.deny(node, "denyNest");
  }

  parentsCannotBeDeleted(node) {
    if (hasVisibleDescendants(node, this.objectType)) this.deny(node, "denyDelete");
  }

  /**
   * Parents cannot be dragged if they have visible children
   */
  parentsCannotBeDragged(node) {
    if (hasVisibleDescendants(node, this.objectType)) this.deny(node, "denyDrag");
  }

  deletedItemsCannotBeEdited(node) {
    if (node.dataset.destroy === "true") this.deny(node, "denyEdit");
  }

  itemCannotHaveInvalidDepth(node) {
    const previous = node.previousElementSibling;
    if (previous && depth(previous, this.objectType) < depth(node, this.objectType) - 1) this.deny(node, "invalidDepth");
  }
}

export {childrenList, index, setIndex, depth, setDepth, RulesEngine};
