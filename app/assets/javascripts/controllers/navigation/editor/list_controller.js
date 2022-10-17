import { Controller } from "@hotwired/stimulus";

export default class ListController extends Controller {
  dragstart(event) {
    if (this.element !== event.target.parentElement) return;

    const target = event.target;
    event.dataTransfer.effectAllowed = "move";

    // update element style after drag has begun
    setTimeout(() => (target.dataset.dragging = ""));
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
      const item = document.createElement("li");
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
    let item = this.dragItem();

    if (!item) return;

    event.preventDefault();
    delete item.dataset.dragging;
    swap(this.dropTarget(event.target), item);

    if (item.dataset.hasOwnProperty("newItem")) {
      const placeholder = item;
      const template = document.createElement("template");
      template.innerHTML = event.dataTransfer.getData("text/html");
      item = template.content.querySelector("li");

      this.element.replaceChild(item, placeholder);
      setTimeout(() =>
        item.querySelector("[role='button'][value='edit']").click()
      );
    }

    this.dispatch("drop", {
      target: item,
      bubbles: true,
      prefix: "navigation",
    });
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
    return e && e.closest("[data-controller='navigation--editor--list'] > *");
  }

  reindex() {
    this.dispatch("reindex", { bubbles: true, prefix: "navigation" });
  }

  reset() {
    this.dispatch("reset", { bubbles: true, prefix: "navigation" });
  }
}

function swap(target, item) {
  if (target && target !== item) {
    const positionComparison = target.compareDocumentPosition(item);
    if (positionComparison & Node.DOCUMENT_POSITION_FOLLOWING) {
      target.insertAdjacentElement("beforebegin", item);
    } else if (positionComparison & Node.DOCUMENT_POSITION_PRECEDING) {
      target.insertAdjacentElement("afterend", item);
    }
  }
}
