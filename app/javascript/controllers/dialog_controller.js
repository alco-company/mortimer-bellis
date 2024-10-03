import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dialog"
export default class extends Controller {
  static targets = [ "dialog", "iframe" ]
  connect() {
  }

  openDialog(e) {
    this.dialogTarget.showModal()
    // this.iframeTarget.src = e.target.dataset.url
  }
}
