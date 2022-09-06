import { Controller } from "@hotwired/stimulus";

export default class ActiveItemController extends Controller {
  static targets = ["menu"];
  static values = {
    cssClass: { type: String, default: "active" },
    addToParents: Boolean
  }

  connect() {
    console.error("connect")
    const item = this.getParent(this.activeLink)
    this.setActiveItem(item);
  }

  get activeLink() {
    return this.menuTarget.querySelector("a[href='" + location.pathname + "']")
  }

  getParent(item) {
    return item.closest("li")
  }

  setActiveItem(item){
    if(item) {
      this.highlightActiveItem(item)
      if(this.addToParentsValue) {
        this.setActiveItem(this.getParent(item.parentNode))
      }
    }
  }

  highlightActiveItem(item) {
    item.classList.add(this.cssClassValue)
  }
}
