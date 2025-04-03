import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list"
export default class extends Controller {
  connect() {
  }

  toggleBatch(event) {
    const checkboxes = document.querySelectorAll('.batch')
    checkboxes.forEach((checkbox) => {
      checkbox.classList.toggle('hidden')
    })
  }

  showBatch(event) {
    const checkboxes = document.querySelectorAll('.batch')
    checkboxes.forEach((checkbox) => {
      checkbox.classList.remove('hidden')
    })
  }

  reload(event) {
    window.location.reload();
  }
}
