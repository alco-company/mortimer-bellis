import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "input",
    "button",
    "indicator",
    "handle"
  ]
  static values = {
    key: String
  }

  csrfToken = null;

  connect() {
    this.csrfToken = document.querySelector("[name='csrf-token']").content;
  }

  toggle(event) {
    event.preventDefault()
    const url = this.element.dataset.url;
    this.toggleIndicator();
    if (url !== undefined && url !== "") {
      this.buttonTarget.ariaBusy = true;
      let method = this.element.dataset.method || "POST";
      fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          Accept: "text/vnd.turbo-stream.html",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({ key: this.keyValue, value: this.inputTarget.value }),
      })
      .then((r) => {
        if (!r.ok) {
          throw new Error(`HTTP error! status: ${r.status}`);
        }
        return JSON.parse(r.text())
      })
      .then((json) => {
        this.buttonTarget.ariaBusy = false;
        if (method === "POST") {
          Turbo.renderStreamMessage(json);
        }
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

  toggleIndicator() {
    let color = this.indicatorTarget.dataset.color || "bg-sky-600"
    if (this.indicatorTarget.classList.contains(color)) {
      this.inputTarget.value = "0"
      this.indicatorTarget.classList.remove(color);
      this.indicatorTarget.classList.add("bg-gray-200");
      this.handleTarget.classList.remove("translate-x-5");
      this.handleTarget.classList.add("translate-x-0");
    } else {
      this.inputTarget.value = "1"
      this.indicatorTarget.classList.remove("bg-gray-200");
      this.indicatorTarget.classList.add(color);
      this.handleTarget.classList.remove("translate-x-0");
      this.handleTarget.classList.add("translate-x-5");
    }
  }
}
