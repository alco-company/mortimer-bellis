import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "input",
    "button",
    "indicator",
    "handle"
  ]

  connect() {
  }

  toggle(event) {
    event.preventDefault()
    console.log(this.indicatorTarget.dataset.color);
    let color = this.indicatorTarget.dataset.color || "bg-sky-600"
    if (this.indicatorTarget.classList.contains(color)) {
      this.inputTarget.value = "0"
      this.indicatorTarget.classList.remove(color);
      this.indicatorTarget.classList.add("bg-gray-200");
      this.handleTarget.classList.remove("translate-x-5");
      this.handleTarget.classList.add("translate-x-0");
    } else {
      this.inputTarget.value = "1"
      this.indicatorTarget.classList.remove("bg-gray-200");
      this.indicatorTarget.classList.add(color);
      this.handleTarget.classList.remove("translate-x-0");
      this.handleTarget.classList.add("translate-x-5");
    }
  }
}
