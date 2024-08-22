import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab", "tabPanel"];

  initialize() {
    this.showTab();
  }

  change(e) {
    this.index = e.target.value;
    this.showTab();
  }

  showTab(i) {
    this.tabPanelTargets.forEach((el, i) => {
      if (i == this.index) {
        el.classList.remove("hidden");
      } else {
        el.classList.add("hidden");
      }
    });
    this.tabTargets.forEach((el, i) => {
      if (i == this.index) {
        el.classList.remove("border-transparent");
        el.classList.add("border-sky-500", "text-sky-600");
      } else {
        el.classList.add("border-transparent");
        el.classList.remove("border-sky-500", "text-sky-600");
      }
    });
  }

  get index() {
    return parseInt(this.data.get("index"));
  }

  set index(value) {
    this.data.set("index", value);
    this.showTab();
  }
}