import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input"
export default class extends Controller {
  connect() {
  }

  help(event) {

    const helpSrc = event.currentTarget.dataset.src;


    if (helpSrc) {
      if (helpSrc.startsWith("http")) {
        // Open the help source in a new tab
        window.open(helpSrc, "_blank");
      }
      else {
        // Open the help source in the same tab
        fetch(helpSrc)
          .then((r) => r.text())
          .then((html) => Turbo.renderStreamMessage(html));

      }
      console.log(`Help source: ${helpSrc}`);
    }
  }
}
