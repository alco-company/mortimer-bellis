import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editor-dnd"
export default class extends Controller {
  static targets = ["dropzone"]

  static values = {
    documentId: String,
  }

  connect() {
    this.dropzoneTarget.addEventListener("dragover", this.dragOver)
    this.dropzoneTarget.addEventListener("drop", this.drop.bind(this))
  }

  disconnect() {
    this.dropzoneTarget.removeEventListener("dragover", this.dragOver)
    this.dropzoneTarget.removeEventListener("drop", this.drop.bind(this))
  }

  dragStart(event) {
    // Get the block type from the data attribute
    const blockType = event.params.blockType

    // Set the data to be transferred
    event.dataTransfer.setData("text/plain", blockType)

    // Optionally, add a class to indicate dragging
    event.currentTarget.classList.add("dragging")
  }

  dragEnd(event) {
    // Remove the dragging class
    event.currentTarget.classList.remove("dragging")
  }

  // Handle drag and drop events
  dragOver(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault()
    const blockType = event.dataTransfer.getData("text/plain")
    // const documentId = this.element.dataset.documentId
    const csrfToken = document.querySelector("[name='csrf-token']").content;
 
    fetch(`/editor/documents/${this.documentIdValue}/blocks`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ type: blockType }),
    })
    .then((r) => r.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
    });
}
}
