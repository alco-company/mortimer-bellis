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
    if (this.indicatorTarget.classList.contains("bg-sky-600")) {
      this.inputTarget.value = "0"
      this.indicatorTarget.classList.remove("bg-sky-600");
      this.indicatorTarget.classList.add("bg-gray-200");
      this.handleTarget.classList.remove("translate-x-5");
      this.handleTarget.classList.add("translate-x-0");
    } else {
      this.inputTarget.value = "1"
      this.indicatorTarget.classList.remove("bg-gray-200");
      this.indicatorTarget.classList.add("bg-sky-600");
      this.handleTarget.classList.remove("translate-x-0");
      this.handleTarget.classList.add("translate-x-5");
    }
  }
}
