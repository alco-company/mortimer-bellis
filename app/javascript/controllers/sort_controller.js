import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = [
    "sortedcontainer"
  ];

  connect() {
    this.debounceTimer = null;

    this.sortable = Sortable.create(this.sortedcontainerTarget, {
      animation: 150,
      onEnd: this.onEnd.bind(this),
    });
    // console.log("Sortable connected", this.sortable);
  }

  disconnect() {
    // if (this.sortable) {
    //   console.log("Destroying Sortable instance");
    //   this.sortable.destroy();
    // }
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
    // console.log("Sortable: ", this.sortable.el);

    const blockIds = this.sortable.toArray()
    const csrfToken = document.querySelector("[name='csrf-token']").content;

    fetch("/editor/blocks/reorder", {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json",
        Accept: "text/vnd.turbo-stream.html",
      },
      body: JSON.stringify({ ids: blockIds }),
    });
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
