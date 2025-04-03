import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list"
export default class extends Controller {
  static targets = [ 
    "item",
  ]

  firstListItemSet = null

  connect() {
    this.firstListItemSet = false
  }


  itemTargetConnected(element) {
    if (!this.firstListItemSet) {
      this.firstListItemSet = true
      let ctx = element.querySelectorAll(".list_context_menu")[0]
      if (ctx){
        ctx.classList.remove("bottom-6");
        ctx.classList.add("top-0")
      }
    }
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
