import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = [ 
    "source"
  ]

  static values = {
    clip: String
  }

  static classes = [
    "supported"
  ]

  copy(event) {
    event.preventDefault();
    navigator.clipboard.writeText(this.clipValue);
  }

  connect() {
    if ("clipboard" in navigator) {
      this.element.classList.add(this.supportedClass);
    }
  }
}
