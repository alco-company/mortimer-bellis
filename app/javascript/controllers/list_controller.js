import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list"
export default class extends Controller {
  static targets = [ 
    "item",
  ]

  connect() {
  }

  toggleBatch(event) {
    const checkboxes = document.querySelectorAll('.batch')
    checkboxes.forEach((checkbox) => {
      checkbox.classList.toggle('hidden')
    })
    // When entering batch mode, make sure we are NOT in "all" mode so that
    // selected IDs are persisted and searches apply only to them.
    const batchAll = document.getElementById('batch_all')
    if (batchAll) { batchAll.checked = false }
  }

  showBatch(event) {
    const checkboxes = document.querySelectorAll('.batch')
    checkboxes.forEach((checkbox) => {
      checkbox.classList.remove('hidden')
    })
    const batchAll = document.getElementById('batch_all')
    if (batchAll) { batchAll.checked = false }
  }

  reload(event) {
    window.location.reload();
  }
}
