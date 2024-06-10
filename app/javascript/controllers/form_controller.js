import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form"
  ]

  connect() {
  }

  clearForm(e) {
    this.formTarget.reset();
  }
}
