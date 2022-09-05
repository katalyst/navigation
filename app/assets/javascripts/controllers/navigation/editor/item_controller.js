import { Controller } from "@hotwired/stimulus";
import Item from "utils/navigation/editor/item";

export default class ItemController extends Controller {
  get item() {
    return new Item(this.li);
  }

  get ol() {
    return this.element.closest("ol");
  }

  get li() {
    return this.element.closest("li");
  }

  connect() {
    if (this.element.dataset.hasOwnProperty("delete")) {
      this.remove();
    }
    // if index is not already set, re-index will set it
    else if (!(this.item.index >= 0)) {
      this.reindex();
    }
    // if item has been replaced via turbo, re-index will run the rules engine
    // update our depth and index with values from the li's data attributes
    else if (this.item.hasItemIdChanged()) {
      this.item.updateAfterChange();
      this.reindex();
    }
  }

  remove() {
    // capture ol
    const ol = this.ol;
    // remove self from dom
    this.li.remove();
    // reindex ol
    this.reindex();
  }

  reindex() {
    this.dispatch("reindex", { bubbles: true, prefix: "navigation" });
  }
}
