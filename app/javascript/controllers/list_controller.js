import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list"
export default class extends Controller {
  static targets = [ 
    "item",
  ]

  connect() {
    this.cleanLocalStorage()
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
    const url = event.target.dataset.url
    Turbo.visit(url)
  }

  cleanLocalStorage() {
    // Clean up any stale timing data in localStorage
    const items = this.itemTargets
    const validKeys = items.map( item => item.id + ":timing" )
    validKeys.push( items.map( item => item.id + ":version" ) )
    validKeys.push( items.map( item => item.id + ":ops" ) )
    // console.log("validKeys", validKeys.flat())
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key.endsWith(":timing") && !validKeys.includes(key)) {
        // console.log(`cleaning stale localStorage key ${key}`)
        localStorage.removeItem(key)
      }
      if (key.endsWith(":version") && !validKeys.includes(key)) {
        // console.log(`cleaning stale localStorage key ${key}`)
        localStorage.removeItem(key)
      }
    }
  }
}
