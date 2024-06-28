import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notice"
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.classList.add('hidden')
    }, 5000)
  }

  close() {
    clearTimeout(this.timeout)
    this.element.classList.add('hidden')
  }
}
