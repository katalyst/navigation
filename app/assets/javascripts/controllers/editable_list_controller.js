import { Controller } from "@hotwired/stimulus";

function swap(target, item) {
  if (target && target !== item) {
    const positionComparison = target.compareDocumentPosition(item);
    if (positionComparison & 4) {
      target.insertAdjacentElement('beforebegin', item);
    } else if (positionComparison & 2) {
      target.insertAdjacentElement('afterend', item);
    }
  }
}

export default class EditableListController extends Controller {
  dragstart(event) {
    if (this.element !== event.target.parentElement) return;

    const target = event.target;
    event.dataTransfer.effectAllowed = "move";

    // update element style after drag has begun
    setTimeout(() => target.dataset.dragging = "");
  }

  dragover(event) {
    const item = this.dragItem();
    if (!item) return;

    swap(this.dropTarget(event.target), item);

    event.preventDefault();
    return true;
  }

  dragenter(event) {
    event.preventDefault();

    if (event.dataTransfer.effectAllowed === "copy" && !this.dragItem()) {
      const item = document.createElement("li")
      item.classList.add("navigation-menu-link");
      item.dataset.dragging = "";
      item.dataset.newItem = "";
      this.element.prepend(item);
    }
  }

  dragleave(event) {
    const item = this.dragItem();
    const related = this.dropTarget(event.relatedTarget);

    // ignore if item is not set or we're moving into a valid drop target
    if (!item || related) return;

    // remove item if it's a new item
    if (item.dataset.hasOwnProperty("newItem")) {
      item.remove();
    }
  }

  drop(event) {
    const item = this.dragItem();

    if (!item) return;

    event.preventDefault();
    delete item.dataset.dragging;
    swap(this.dropTarget(event.target), item);

    if (item.dataset.hasOwnProperty("newItem")) {
      const template = document.createElement("template");
      template.innerHTML = event.dataTransfer.getData("text/html");
      const newItem = template.content.querySelector("li");

      this.element.replaceChild(newItem, item);
      setTimeout(() => newItem.querySelector("a.navigation-editor--item--edit").click());
    }

    this.reindex();
  }

  dragend() {
    const item = this.dragItem();
    if (!item) return;

    delete item.dataset.dragging;
    this.reset();
  }

  dragItem() {
    return this.element.querySelector("[data-dragging]");
  }

  dropTarget(e) {
    return e && e.closest("[data-controller~='editable-list'] > *");
  }

  reindex() {
    this.element.dispatchEvent(new CustomEvent("reindex"));
  }

  reset() {
    this.element.dispatchEvent(new CustomEvent("reset"));
  }
}
