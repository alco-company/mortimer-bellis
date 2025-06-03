import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.debounceTimer = null;

    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      onEnd: this.onEnd.bind(this),
    });
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy();
    }
  }
  // Debounce function to limit the frequency of updates
  debounce(func, delay) {
    return (...args) => {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = setTimeout(() => func.apply(this, args), delay);
    };
  }
  // Handle the end of a drag-and-drop operation
  // This function is called when the user drops a block in a new position
  reorderBlocks() {
    const blockIds = this.sortable.toArray()

    fetch("/editor/blocks/reorder", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ ids: blockIds })
    })
  }

  async onEnd(event) {
    this.debounce(this.reorderBlocks.bind(this), 300)();
    // const blockIds = this.sortable.toArray();

    // await fetch(`/editor/blocks/reorder`, {
    //   method: "PATCH",
    //   headers: {
    //     "Content-Type": "application/json",
    //     "Accept": "text/vnd.turbo-stream.html"
    //   },
    //   body: JSON.stringify({ ids: blockIds }),
    // });
  }
}
