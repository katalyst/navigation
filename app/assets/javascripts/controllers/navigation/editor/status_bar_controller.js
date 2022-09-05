import { Controller } from "@hotwired/stimulus";

export default class StatusBarController extends Controller {
  connect() {
    // cache the version's state in the controller on connect
    this.versionState = this.element.dataset.state;
  }

  change(e) {
    if (e.detail && e.detail.hasOwnProperty("dirty")) {
      this.update(e.detail);
    }
  }

  update({ dirty }) {
    if (dirty) {
      this.element.dataset.state = "dirty";
    } else {
      this.element.dataset.state = this.versionState;
    }
  }
}
