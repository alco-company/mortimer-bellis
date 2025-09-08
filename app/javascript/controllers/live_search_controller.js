import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { url: String, delay: { type: Number, default: 500 } }

  connect() {
    this.timer = null
    // this.lastValue = new URLSearchParams(window.location.search).get('search') || this.inputTarget.value || ""
    // this.inputTarget.focus()
    // const val = this.inputTarget.value
    // this.inputTarget.value = ""
    // this.inputTarget.value = val
  }

  search(event) {
    if (event && event.isComposing) return
    const value = this.inputTarget.value.trim()
    if (value === this.lastValue) return
    // clearTimeout(this.timer)
    const run = () => {
      this.lastValue = value
      // Build a URL object from either provided urlValue or current location
      let base
      try {
        if (this.urlValue) {
          base = new URL(this.urlValue, window.location.origin)
        } else {
          base = new URL(window.location.href)
        }
      } catch (_) {
        base = new URL(window.location.href)
      }
      const params = base.searchParams
      if (value.length > 0) {
        params.set('search', value)
      } else {
        params.delete('search')
      }
      params.set('replace', 'true')
      // Reconstruct clean URL (avoid duplicated query pieces)
      const query = params.toString()
      const finalUrl = query.length > 0 ? `${base.pathname}?${query}` : base.pathname
      Turbo.visit(finalUrl, { action: 'replace' })
    }
    if (event && event.type === 'input' && event.inputType === 'insertLineBreak') {
      run()
      return
    }
    if (event && event.key === 'Enter') {
      run()
      return
    }
    // this.timer = setTimeout(run, this.delayValue)
  }
}
