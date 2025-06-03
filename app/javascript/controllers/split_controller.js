import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.isResizing = false;
    this.editor = document.getElementById("editor-container");

    // Load width from localStorage
    const savedWidth = localStorage.getItem("editorPaneWidth");
    if (savedWidth) {
      this.editor.style.width = `${savedWidth}px`;
    }
  }

  startResize(event) {
    this.isResizing = true
    this.startX = event.clientX
    this.editor = document.getElementById("editor-container")
    this.preview = document.getElementById("preview-pane")

    document.addEventListener("mousemove", this.resizePane)
    document.addEventListener("mouseup", this.stopResize)
  }

  resizePane = (event) => {
    if (!this.isResizing) return;

    const dx = event.clientX - this.startX;
    const newWidth = this.editor.offsetWidth + dx;
    this.editor.style.width = `${newWidth}px`;
    this.startX = event.clientX;

    // Save to localStorage
    localStorage.setItem("editorPaneWidth", newWidth);
  }

  stopResize = () => {
    this.isResizing = false
    document.removeEventListener("mousemove", this.resizePane)
    document.removeEventListener("mouseup", this.stopResize)
  }
}