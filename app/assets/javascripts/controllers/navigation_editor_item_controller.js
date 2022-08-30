import { Controller } from "@hotwired/stimulus";
import { index, depth } from "./utils/rules-engine";

const objectType = "navigation";

// request a re-index from the parent to set/initialise index and depth
function dispatchReindex(target) {
  target.dispatchEvent(new CustomEvent("reindex", { bubbles: true }));
}

export default class NavigationEditorItemController extends Controller {

  get ol() {
    return this.element.parentNode.parentNode;
  }

  get li() {
    return this.element.parentNode;
  }

  get indexInput() {
    return this.element.querySelector(`[data-navigation-index-input]`);
  }

  get depthInput() {
    return this.element.querySelector(`[data-navigation-depth-input]`);
  }

  connect() {
    if(this.element.dataset.hasOwnProperty("delete")) {
      // capture ol
      const ol = this.ol;
      // remove self from dom
      this.li.remove();
      // reindex ol
      dispatchReindex(ol);
    } else {
      // initialize index and depth
      this.reindex();
    }
  }

  reindex() {
    // if index is not already set we can call re-index to set it
    if (!index(this.li, objectType) >= 0) {
      dispatchReindex(this.element);
    }

    // update our inputs with values from the li's data attributes
    this.indexInput.value = index(this.li, objectType);
    this.depthInput.value = depth(this.li, objectType);
  }
}
