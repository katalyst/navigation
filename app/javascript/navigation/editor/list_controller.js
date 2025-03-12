import { Controller } from "@hotwired/stimulus";

export default class ListController extends Controller {
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
   * When the user drops an item, end the drag and reindex the list.
   *
   * @param event {DragEvent}
   */
  drop(event) {
    let item = this.dragItem;

    if (!item) return;

    event.preventDefault();
    delete item.dataset.dragging;
    swap(dropTarget(event.target), item);

    this.dispatch("drop", {
      target: item,
      bubbles: true,
      prefix: "navigation",
    });
  }

  /**
   * End an in-progress drag by resetting the item's style and restoring its
   * original position in the list.
   */
  dragend() {
    const item = this.dragItem;

    if (item) {
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
 * Swaps two list items.
 *
 * @param target the target element to swap with
 * @param item the item the user is dragging
 */
function swap(target, item) {
  if (!target) return;
  if (target === item) return;

  const positionComparison = target.compareDocumentPosition(item);
  if (positionComparison & Node.DOCUMENT_POSITION_FOLLOWING) {
    target.insertAdjacentElement("beforebegin", item);
  } else if (positionComparison & Node.DOCUMENT_POSITION_PRECEDING) {
    target.insertAdjacentElement("afterend", item);
  }
}

/**
 * Given an event target, return the closest drop target, if any.
 */
function dropTarget(e) {
  return e && e.closest("[data-controller='navigation--editor--list'] > *");
}
