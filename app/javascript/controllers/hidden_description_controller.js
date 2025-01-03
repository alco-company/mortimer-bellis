import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden-description"
export default class extends Controller {
  static targets = [
    'description'
  ]

  connect() {
  }

  toggle(e) {
    e = e.target
    console.log(e.tagName)
    if (e.tagName === 'path') {
      e = e.parentElement
    }
    if (e.classList.contains('rotate-180')) {
      e.classList.remove('rotate-180')
    } else {
      e.classList.add('rotate-180')
    }
    this.descriptionTarget.classList.toggle("hidden");
  }
}
