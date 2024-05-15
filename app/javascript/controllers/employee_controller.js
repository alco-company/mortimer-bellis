import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="employee"
export default class extends Controller {
  static targets = [
    "advanced"
  ]

  connect() {
  }

  toggleAdvanced(e) {
    if (this.advancedTarget.classList.contains("hidden")) {
      this.advancedTarget.classList.remove("hidden");
      e.target.classList.add("hidden");
    } else {
      this.advancedTarget.classList.add("hidden");
    }
  }
}
