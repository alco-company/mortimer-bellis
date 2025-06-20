import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "input",
    "output",
    "editbutton",
    "savebutton"
  ]
  static values = {
    key: String
  }

  csrfToken = null;

  connect() {
    this.csrfToken = document.querySelector("[name='csrf-token']").content;
  }

  edit(event) {
    event.preventDefault();
    console.log("edit", this.keyValue);
    this.inputTarget.classList.remove("hidden");
    this.outputTarget.classList.add("hidden");
    this.editbuttonTarget.classList.add("hidden");
    this.savebuttonTarget.classList.remove("hidden");
    this.inputTarget.focus();
  }

  update(event) {
    event.preventDefault()
    const url = this.element.dataset.url;
    if (url !== undefined && url !== "") {
      this.savebuttonTarget.ariaBusy = true;
      let method = this.element.dataset.method || "POST";
      fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({ key: this.keyValue, value: this.inputTarget.value }),
      })
      .then((r) => r.text())
      .then((html) => {
        this.savebuttonTarget.ariaBusy = false;
        Turbo.renderStreamMessage(html);
      })

      // .then((response) => response.json())
      // .then((data) => {
      //   this.toggleIndicator();
      //   console.log("response:", data);
      //   this.buttonTarget.ariaBusy = false;
      // })
      .catch((error) => {
        console.error("Error:", error);
        this.buttonTarget.ariaBusy = false;
      });
    }
  }
}
