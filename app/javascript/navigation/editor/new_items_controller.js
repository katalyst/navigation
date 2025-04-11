import { Controller } from "@hotwired/stimulus";

import Item from "./item";

const EDGE_AREA = 24;

export default class NewItemsController extends Controller {
  static targets = ["inline"];

  connect() {
    this.form.addEventListener("mousemove", this.move);
  }

  disconnect() {
    this.form?.removeEventListener("mousemove", this.move);
    delete this.currentItem;
  }

  click(e) {
    if (e.target.tagName === "DIALOG") this.close(e);
  }

  open(e) {
    e.preventDefault();
    this.dialog.showModal();
  }

  close(e) {
    e.preventDefault();
    this.dialog.close();
  }

  /**
   * Add the selected item to the DOM at the current position or the end of the list.
   */
  add(e) {
    e.preventDefault();

    const template = e.target.closest("li").querySelector("template");
    const item = template.content.querySelector("li").cloneNode(true);
    const target = this.currentItem;

    if (target) {
      target.insertAdjacentElement("beforebegin", item);
      new Item(item).depth = new Item(target).depth;
    } else {
      this.list.insertAdjacentElement("beforeend", item);
    }

    this.toggleInline(false);
    this.dialog.close();

    requestAnimationFrame(() => {
      item.querySelector(`[value="edit"]`).click();
    });
  }

  morph(e) {
    e.preventDefault();
    this.dialog.close();
  }

  move = (e) => {
    if (this.isOverInlineTarget(e)) return;
    if (this.dialog.open) return;

    const target = this.getCurrentItem(e);

    // return if we're already showing this item
    if (this.currentItem === target) return;

    // hide the button if it's already visible
    if (this.currentItem) this.toggleInline(false);

    this.currentItem = target;

    // clear any previously set timer
    if (this.timer) clearTimeout(this.timer);

    // show the button after a debounce pause
    this.timer = setTimeout(() => {
      delete this.timer;
      this.toggleInline();
    }, 100);
  };

  toggleInline(show = !!this.currentItem) {
    if (show) {
      this.inlineTarget.style.top = `${this.currentItem.offsetTop}px`;
      this.inlineTarget.toggleAttribute("hidden", false);
    } else {
      this.inlineTarget.toggleAttribute("hidden", true);
    }
  }

  get dialog() {
    return this.element.querySelector("dialog");
  }

  /**
   * @returns {HTMLFormElement}
   */
  get form() {
    return this.element.closest("form");
  }

  /**
   * @returns {HTMLUListElement,null}
   */
  get list() {
    return this.form.querySelector(
      `[data-controller="navigation--editor--list"]`,
    );
  }

  /**
   * @param {MouseEvent} e
   * @returns {HTMLLIElement,null}
   */
  getCurrentItem(e) {
    const item = document.elementFromPoint(e.clientX, e.clientY).closest("li");
    if (!item) return null;

    const bounds = item.getBoundingClientRect();

    // check X for center(ish) mouse position
    if (e.clientX < bounds.left + bounds.width / 2 - 2 * EDGE_AREA) return null;
    if (e.clientX > bounds.left + bounds.width / 2 + 2 * EDGE_AREA) return null;

    // check Y for hits on this item or it's next sibling
    if (e.clientY - bounds.y <= EDGE_AREA) {
      return item;
    } else if (bounds.y + bounds.height - e.clientY <= EDGE_AREA) {
      return item.nextElementSibling;
    } else {
      return null;
    }
  }

  /**
   * @param {MouseEvent} e
   * @returns {Boolean} true when the target of the event is the floating button
   */
  isOverInlineTarget(e) {
    return (
      this.inlineTarget ===
      document.elementFromPoint(e.clientX, e.clientY).closest("div")
    );
  }
}
