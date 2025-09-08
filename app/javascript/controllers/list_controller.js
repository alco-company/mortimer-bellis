import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list"
export default class extends Controller {
  static targets = [ 
    "item",
  ]

  connect() {
  }


  // itemTargetConnected(element) {
  //   if (!this.firstListItemSet) {
  //     this.firstListItemSet = true
  //     let ctxs = document.querySelectorAll(".list_context_menu")
  //     if (ctxs.length > 0){
  //       let ctx = ctxs[ ctxs.length - 1 ]
  //       ctx.classList.remove("top-0");
  //       ctx.classList.add("bottom-6");
  //     }
  //   }
  // }

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
