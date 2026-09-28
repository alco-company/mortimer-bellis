import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    siteKey: String,
  }

  connect() {
    this.renderWhenReady()
  }

  renderWhenReady() {
    if (window.turnstile && typeof window.turnstile.render === "function") {
      window.turnstile.render(this.element, {
        sitekey: this.siteKeyValue,
        callback: this.callback.bind(this),
      })
      return
    }

    requestAnimationFrame(() => this.renderWhenReady())
  }

  callback(token) {
    this.dispatch("success", {
      detail: { token },
    })
  }
}
