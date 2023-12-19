import { Controller } from "@hotwired/stimulus";

export default class ListController extends Controller {
  connect() {
    this.enterCount = 0;
  }

  /**
   * When the user starts a drag within the list, set the item's dataTransfer
   * properties to indicate that it's being dragged and update its style.
   *
   * We delay setting the dataset property until the next animation frame
   * so that the style updates can be computed before the drag begins.
   *
   * @param event {DragEvent}
   */
  dragstart(event) {
    if (this.element !== event.target.parentElement) return;

    const target = event.target;
    event.dataTransfer.effectAllowed = "move";

    // update element style after drag has begun
    requestAnimationFrame(() => (target.dataset.dragging = ""));
  }

  /**
   * When the user drags an item over another item in the last, swap the
   * dragging item with the item under the cursor.
   *
   * As a special case, if the item is dragged over placeholder space at the end
   * of the list, move the item to the bottom of the list instead. This allows
   * users to hit the list element more easily when adding new items to an empty
   * list.
   *
   * @param event {DragEvent}
   */
  dragover(event) {
    const item = this.dragItem;
    if (!item) return;

    swap(dropTarget(event.target), item);

    event.preventDefault();
    return true;
  }

  /**
   * When the user drags an item into the list, create a placeholder item to
   * represent the new item. Note that we can't access the drag data
   * until drop, so we assume that this is our template item for now.
   *
   * Users can cancel the drag by dragging the item out of the list or by
   * pressing escape. Both are handled by `cancelDrag`.
   *
   * @param event {DragEvent}
   */
  dragenter(event) {
    event.preventDefault();

    // Safari doesn't support relatedTarget, so we count enter/leave pairs
    this.enterCount++;

    if (copyAllowed(event) && !this.dragItem) {
      const item = document.createElement("li");
      item.dataset.dragging = "";
      item.dataset.newItem = "";
      this.element.appendChild(item);
    }
  }

  /**
   * When the user drags the item out of the list, remove the placeholder.
   * This allows users to cancel the drag by dragging the item out of the list.
   *
   * @param event {DragEvent}
   */
  dragleave(event) {
    // Safari doesn't support relatedTarget, so we count enter/leave pairs
    // https://bugs.webkit.org/show_bug.cgi?id=66547
    this.enterCount--;

    if (
      this.enterCount <= 0 &&
      this.dragItem.dataset.hasOwnProperty("newItem")
    ) {
      this.cancelDrag(event);
    }
  }

  /**
   * When the user drops an item into the list, end the drag and reindex the list.
   *
   * If the item is a new item, we replace the placeholder with the template
   * item data from the dataTransfer API.
   *
   * @param event {DragEvent}
   */
  drop(event) {
    let item = this.dragItem;

    if (!item) return;

    event.preventDefault();
    delete item.dataset.dragging;
    swap(dropTarget(event.target), item);

    if (item.dataset.hasOwnProperty("newItem")) {
      const placeholder = item;
      const template = document.createElement("template");
      template.innerHTML = event.dataTransfer.getData("text/html");
      item = template.content.querySelector("li");

      this.element.replaceChild(item, placeholder);
      requestAnimationFrame(() =>
        item.querySelector("[role='button'][value='edit']").click()
      );
    }

    this.dispatch("drop", {
      target: item,
      bubbles: true,
      prefix: "navigation",
    });
  }

  /**
   * End an in-progress drag. If the item is a new item, remove it, otherwise
   * reset the item's style and restore its original position in the list.
   */
  dragend() {
    const item = this.dragItem;

    if (!item) {
    } else if (item.dataset.hasOwnProperty("newItem")) {
      item.remove();
    } else {
      delete item.dataset.dragging;
      this.reset();
    }
  }

  get isDragging() {
    return !!this.dragItem;
  }

  get dragItem() {
    return this.element.querySelector("[data-dragging]");
  }

  reindex() {
    this.dispatch("reindex", { bubbles: true, prefix: "navigation" });
  }

  reset() {
    this.dispatch("reset", { bubbles: true, prefix: "navigation" });
  }
}

/**
 * Swaps two list items. If target is a list, the item is appended.
 *
 * @param target the target element to swap with
 * @param item the item the user is dragging
 */
function swap(target, item) {
  if (!target) return;
  if (target === item) return;

  if (target.nodeName === "LI") {
    const positionComparison = target.compareDocumentPosition(item);
    if (positionComparison & Node.DOCUMENT_POSITION_FOLLOWING) {
      target.insertAdjacentElement("beforebegin", item);
    } else if (positionComparison & Node.DOCUMENT_POSITION_PRECEDING) {
      target.insertAdjacentElement("afterend", item);
    }
  }

  if (target.nodeName === "OL") {
    target.appendChild(item);
  }
}

/**
 * Returns true if the event supports copy or copy move.
 *
 * Chrome and Firefox use copy, but Safari only supports copyMove.
 */
function copyAllowed(event) {
  return (
    event.dataTransfer.effectAllowed === "copy" ||
    event.dataTransfer.effectAllowed === "copyMove"
  );
}

/**
 * Given an event target, return the closest drop target, if any.
 */
function dropTarget(e) {
  return (
    e &&
    (e.closest("[data-controller='navigation--editor--list'] > *") ||
      e.closest("[data-controller='navigation--editor--list']"))
  );
}
