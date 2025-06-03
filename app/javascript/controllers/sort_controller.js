import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      animation: 150,
      onEnd: this.onEnd.bind(this),
    });
  }

  async onEnd(event) {
    const blockIds = this.sortable.toArray();

    await fetch(`/editor/blocks/reorder`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ ids: blockIds }),
    });
  }
}
