import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.setSizeFromStorage();
  }

  setSize(event) {
    const size = event.params.size;
    this.applySize(size);
    localStorage.setItem("previewDeviceSize", size);
  }

  applySize(size) {
    const container = this.containerTarget;
    console.log("Applying size:", size);
    console.log(this.containerTarget);
    if (size === "full") {
      container.style.width = "100%";
      container.style.maxWidth = "none";
    } else {
      container.style.width = `${size}px`;
      container.style.maxWidth = "100%";
    }
  }

  setSizeFromStorage() {
    let savedSize = localStorage.getItem("previewDeviceSize");
    savedSize === "undefined" ? savedSize = "full" : savedSize;
    this.applySize(savedSize);
  }
}
