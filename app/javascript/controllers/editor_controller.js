import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editor"
export default class extends Controller {
  static targets = ["input", "preview"]

  content = null
  // local update
  // update() {
  //   const html = this.inputTarget.value
  //   this.previewTarget.innerHTML = html
  // }

  // server side rendering
  // level up
  //
  update() {
    clearTimeout(this.timer)
    if (this.inputTarget.value.trim() != this.content) {
      this.timer = setTimeout(() => {
        const documentId = this.element.dataset.documentId;
        const csrfToken = document.querySelector("[name='csrf-token']").content;
        this.content = this.inputTarget.value.trim();

        fetch(`/editor/documents/${documentId}/blocks`, {
          method: "POST",
          headers: {
            "X-CSRF-Token": csrfToken,
            Accept: "text/vnd.turbo-stream.html",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ doc: this.inputTarget.value }),
        })
          .then((res) => res.text())
          .then((html) => {
            this.previewTarget.innerHTML = html;
          });
      }, 300); // debounce
    }
  }
}
