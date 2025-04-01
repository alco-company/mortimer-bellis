import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list-item"
export default class extends Controller {
  connect() {
    this.showBatch(null)
  }

  showBatch(event) {
    if (document.getElementById('batch_all').classList.contains('hidden')) return
    this.element.querySelector('input').classList.remove('hidden')
  }

}
