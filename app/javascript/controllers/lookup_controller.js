import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lookup"
export default class extends Controller {
  static targets = [
    "input",
    "lookup_options"
  ]

  connect() {
    console.log("Connected to lookup controller")
    this.inputTarget.addEventListener("input", this.change.bind(this));
  }

  key_down(e) {
    console.log(`you pressed ${e.key}`);
  }

  change(e) {
    const input = e.target;
    const list = document.querySelector(`#${input.getAttribute("list")}`);
    const value = input.value.toLowerCase();
    let found = false;

    console.log(`${value} ${list}`);

    // for (let i = 0; i < options.length; i++) {
    //   const option = options[i];
    //   if (option.value.toLowerCase() === value) {
    //     found = true;
    //     break;
    //   }
    // }

    // if (!found) {
    //   input.value = "";
    // }
  }
}
