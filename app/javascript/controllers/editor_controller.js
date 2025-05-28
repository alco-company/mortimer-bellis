import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editor"
export default class extends Controller {
  static targets = ["input", "preview"]

  // local update
  update() {
    const html = this.inputTarget.value
    this.previewTarget.innerHTML = html
  }

  // server side rendering
  // level up
  //
  // update() {
  //   clearTimeout(this.timer)
  //   this.timer = setTimeout(() => {
  //     fetch("/editor", {
  //       method: "POST",
  //       headers: { "Content-Type": "application/json" },
  //       body: JSON.stringify({ doc: this.inputTarget.value })
  //     })
  //     .then(res => res.text())
  //     .then(html => {
  //       this.previewTarget.innerHTML = html
  //     })
  //   }, 300) // debounce
  // }
}
