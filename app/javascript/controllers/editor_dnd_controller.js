import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editor-dnd"
export default class extends Controller {
  static targets = ["dropzone"]

  static values = {
    documentId: String,
  }

  origin = null;
  draggedBlockId = null;
  
  connect() {
    this.dropzoneTarget.addEventListener("dragover", this.dragOver)
    this.dropzoneTarget.addEventListener("drop", this.drop.bind(this))
  }

  disconnect() {
    this.dropzoneTarget.removeEventListener("dragover", this.dragOver)
    this.dropzoneTarget.removeEventListener("drop", this.drop.bind(this))
  }

  dragStart(event) {
    this.origin = event.target.dataset.origin;
    const blockType = event.target.dataset.blockType;

    // Store the block type in the dataTransfer object
    if (this.origin === "palette") {
      event.dataTransfer.setData("text/plain", blockType);
    } else if (this.origin === "canvas") {
      this.draggedBlockId = event.target.dataset.blockId;
    }
    // Optionally, add a class to indicate dragging
    event.currentTarget.classList.add("dragging")
  }

  dragEnd(event) {
    // Remove the dragging class
    this.origin = null;
    this.draggedBlockId = null;
    event.currentTarget.classList.remove("dragging")
  }

  // Handle drag and drop events
  dragOver(event) {
    event.preventDefault()
    event.currentTarget.classList.add("bg-blue-200");
  }

  drop(event) {
    // event.preventDefault();
    // const parentId = event.currentTarget.dataset.blockId || null;

    // if (this.origin === "palette") {
    //   const blockType = event.dataTransfer.getData("text/plain");
    //   this.createBlock(this.documentIdValue, blockType, parentId);
    // } else if (this.origin === "canvas" && this.draggedBlockId) {
    //   this.moveBlock(this.draggedBlockId, parentId);
    // }

    // this.origin = null;
    // this.draggedBlockId = null;

    event.preventDefault();

    const dropTargetBlockId = event.currentTarget.dataset.blockId;
    const dropPosition = event.currentTarget.dataset.dropPosition;
    const documentId = this.element.dataset.documentId;

    if (this.origin === "canvas" && this.draggedBlockId) {
      this.moveBlock(this.draggedBlockId, {
        siblingId: dropTargetBlockId,
        position: dropPosition,
      });
    } else if (this.origin === "palette") {
      const blockType = event.dataTransfer.getData("text/plain");
      this.createBlock(this.documentIdValue, blockType, {
        siblingId: dropTargetBlockId,
        position: dropPosition,
      });
    }

    this.origin = null;
    this.draggedBlockId = null;
  }


  createBlock(documentId, type, { siblingId, position }) {
    const csrfToken = document.querySelector("[name='csrf-token']").content;
    fetch(`/editor/documents/${documentId}/blocks`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ type, parent_id: siblingId, drag_position: position }),
    })
    .then((r) => r.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
    });
  }

  moveBlock(blockId, { siblingId, position }) {
    const csrfToken = document.querySelector("[name='csrf-token']").content;
    fetch(`/editor/blocks/${blockId}/move`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sibling_id: siblingId,
        drop_position: position,
      }),
    })
    .then((r) => r.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
    });
  }
}
