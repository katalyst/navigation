import { Controller } from "@hotwired/stimulus";

export default class NewItemController extends Controller {
  static targets = ["template"];

  dragstart(event) {
    if (this.element !== event.target) return;

    event.dataTransfer.setData("text/html", this.templateTarget.innerHTML);
    event.dataTransfer.effectAllowed = "copy";
  }
}
