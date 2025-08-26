import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { url: String, delay: { type: Number, default: 300 } }

  connect() {
    this.timer = null
    this.inputTarget.focus()
    var val = this.inputTarget.value; //store the value of the element
    this.inputTarget.value = ""; //clear the value of the element
    this.inputTarget.value = val;
  }

  search(event) {
    clearTimeout(this.timer)
    const value = this.inputTarget.value
    this.timer = setTimeout(() => {
      const params = new URLSearchParams(window.location.search)
      if (value.length > 0) {
        params.set('search', value)
      } else {
        params.delete('search')
      }
      params.set('replace', 'true')
      const url = `${this.urlValue || window.location.pathname}?${params.toString()}`
      Turbo.visit(url)
    }, this.delayValue)
  }
}
