import { Controller } from "@hotwired/stimulus";

import Item from "utils/navigation/editor/item";
import Menu from "utils/navigation/editor/menu";
import RulesEngine from "utils/navigation/editor/rules-engine";

export default class MenuController extends Controller {
  static targets = ["menu"];

  connect() {
    this.state = this.menu.state;

    this.reindex();
  }

  get menu() {
    return new Menu(this.menuTarget);
  }

  reindex() {
    this.menu.reindex();
    this.#update();
  }

  reset() {
    this.menu.reset();
  }

  remove(event) {
    const item = getEventItem(event);

    item.node.remove();

    this.#update();
    event.preventDefault();
  }

  nest(event) {
    const item = getEventItem(event);

    item.traverse((child) => {
      child.depth += 1;
    });

    this.#update();
    event.preventDefault();
  }

  deNest(event) {
    const item = getEventItem(event);

    item.traverse((child) => {
      child.depth -= 1;
    });

    this.#update();
    event.preventDefault();
  }

  collapse(event) {
    const item = getEventItem(event);

    item.collapse();

    this.#update();
    event.preventDefault();
  }

  expand(event) {
    const item = getEventItem(event);

    item.expand();

    this.#update();
    event.preventDefault();
  }

  /**
   * Re-apply rules to items to enable/disable appropriate actions.
   */
  #update() {
    // debounce requests to ensure that we only update once per tick
    this.updateRequested = true;
    setTimeout(() => {
      if (!this.updateRequested) return;

      this.updateRequested = false;
      const engine = new RulesEngine();
      this.menu.items.forEach((item) => engine.update(item));

      this.#notifyChange();
    }, 0);
  }

  #notifyChange() {
    this.dispatch("change", {
      bubbles: true,
      prefix: "navigation",
      detail: { dirty: this.#isDirty() },
    });
  }

  #isDirty() {
    return this.menu.state !== this.state;
  }
}

function getEventItem(event) {
  return new Item(event.target.closest("[data-navigation-item]"));
}