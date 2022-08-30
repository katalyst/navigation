import { Controller } from "@hotwired/stimulus";
import { childrenList, index, setIndex, depth, setDepth, RulesEngine } from "./utils/rules-engine";

const objectType = "navigation";

function item(event) {
  return event.target.closest("[data-navigation-item]");
}

/**
 * Returns navigation nodes that are visible and logically nested below the given node.
 *
 * @param node
 * @returns {Element[]}
 */
function visibleDescendants(node) {
  const descendants = [];

  for (let sibling = node.nextElementSibling; sibling && depth(sibling, objectType) > depth(node, objectType); sibling = sibling.nextElementSibling) {
    descendants.push(sibling);
  }

  return descendants;
}

/**
 * Returns navigation nodes that have been collapsed into the given node.
 *
 * @param node
 * @returns {Element[]}
 */
function hiddenDescendants(node) {
  return Array.from(childrenList(node, objectType).children);
}

function blur(event) {
  event.target.closest("button").blur();
}

function compare(a, b) {
  return index(a, objectType) - index(b, objectType);
}

export default class NavigationController extends Controller {
  static targets = ["menu"]

  connect() {
    this.state = this.computeState();

    this.reindex();
  }

  reindex() {
    this.navItems().map((node, index) => setIndex(node, index, objectType));
    this.updateNavItems();
  }

  reset() {
    this.navItems().sort(compare).forEach(node => this.menuTarget.appendChild(node));
  }

  navItems() {
    return Array.from(this.menuTarget.querySelectorAll("[data-navigation-index]"));
  }

  updateNavItems() {
    // debounce requests to ensure that we only update once per tick
    this.updateRequested = true;
    setTimeout(() => {
      if (!this.updateRequested) return;

      this.updateRequested = false;
      new RulesEngine(objectType).update(this.navItems())
      this.element.dispatchEvent(new CustomEvent("change", {
        bubbles: true,
        detail: { dirty: this.computeState() !== this.state }
      }));
    }, 0);
  }

  remove(event) {
    const node = item(event);

    node.remove();
    this.updateNavItems();

    event.preventDefault();
  }

  nest(event) {
    const node = item(event);

    setDepth(node, depth(node, objectType) + 1, objectType);

    hiddenDescendants(node).forEach(node => setDepth(node, depth(node, objectType) + 1, objectType));

    this.updateNavItems();

    blur(event);
    event.preventDefault();
  }

  deNest(event) {
    const node = item(event);

    setDepth(node, depth(node, objectType) - 1, objectType);

    hiddenDescendants(node).forEach(node => setDepth(node, depth(node, objectType) - 1, objectType));

    this.updateNavItems();

    blur(event);
    event.preventDefault();
  }

  collapse(event) {
    const node = item(event);
    const children = childrenList(node, objectType);

    visibleDescendants(node).forEach(e => children.appendChild(e));

    this.updateNavItems();

    blur(event);
    event.preventDefault();
  }

  expand(event) {
    const node = item(event);

    hiddenDescendants(node).reverse().forEach(item => node.insertAdjacentElement('afterend', item));

    this.updateNavItems();

    blur(event);
    event.preventDefault();
  }

  computeState() {
    return Array.from(this.element.querySelectorAll("li input[type=hidden]")).map(e => e.value).join('/');
  }
}
