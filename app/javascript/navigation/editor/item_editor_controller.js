import { Controller } from "@hotwired/stimulus";
import Item from "./item";

export default class ItemEditorController extends Controller {
  static targets = ["dialog"];

  connect() {
    this.element.addEventListener("turbo:submit-end", this.onSubmit);
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.onSubmit);
  }

  click(e) {
    if (e.target.tagName === "DIALOG") this.dismiss();
  }

  dismiss() {
    if (!this.dialogTarget) return;
    if (!this.dialogTarget.open) this.dialogTarget.close();

    if (!("itemPersisted" in this.dialogTarget.dataset)) {
      this.#removeTargetItem();
    }

    this.element.removeAttribute("src");
    this.dialogTarget.remove();
  }

  dialogTargetConnected(dialog) {
    dialog.showModal();
  }

  onSubmit = (event) => {
    if (
      event.detail.success &&
      "closeDialog" in event.detail.formSubmission?.submitter?.dataset
    ) {
      this.dialogTarget.close();
      this.element.removeAttribute("src");
      this.dialogTarget.remove();
    }
  };

  #removeTargetItem() {
    const el = document.getElementById(this.dialogTarget.dataset.itemId);
    const item = new Item(el.closest("[data-navigation-item]"));
    const list = item.node.parentElement;

    item.node.remove();

    this.dispatch("reindex", {
      target: list,
      bubbles: true,
      prefix: "navigation",
    });
  }
}
