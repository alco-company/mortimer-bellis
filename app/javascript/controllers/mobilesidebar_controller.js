import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

// Connects to data-controller="mobilesidebar"
export default class extends Controller {
  static targets = ["container", "backdrop", "panel", "closeButton"];

  reload() {
    window.location.reload();
  }
  show() {
    this.containerTarget.classList.remove("hidden");
    enter(this.backdropTarget);
    enter(this.closeButtonTarget);
    enter(this.panelTarget);
  }

  hide() {
    Promise.all([
      leave(this.backdropTarget),
      leave(this.closeButtonTarget),
      leave(this.panelTarget),
    ]).then(() => {
      this.containerTarget.classList.add("hidden");
    });
  }
}
