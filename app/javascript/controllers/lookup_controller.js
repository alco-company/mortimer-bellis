import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lookup"
export default class extends Controller {
  static targets = [
    "input",
    "selectId",
    "lookup_options",
    "searchIcon",
    "optionsIcon"
  ]

  connect() {
    console.log("Connected to lookup controller")
    this.inputTarget.addEventListener("input", this.change.bind(this));
  }

  key_down(e) {
    console.log(`you pressed ${e.key}`);
  }

  select_option(e) {
    let el = e.target;
    while ('LI' !== el.nodeName) {
      el = el.parentElement;
    }
    this.inputTarget.value = el.dataset.displayValue;
    this.selectIdTarget.value = el.dataset.value;
    el.closest("UL").querySelectorAll("LI > SPAN > SVG").forEach((e) => {
      e.parentElement.classList.add("hidden");
    });
    el.querySelectorAll("LI > SPAN > SVG").forEach((e) => {
      e.parentElement.classList.remove("hidden");
    })
    el.closest("DIV").classList.add("hidden");
  }

  change(e) {
    this.optionsIconTarget.classList.add("hidden");
    this.searchIconTarget.classList.remove("hidden");
  }

  toggleOptions(e) {
    const options = this.lookup_optionsTarget;
    if (options.classList.contains("hidden")) {
      options.classList.remove("hidden");
    } else {
      options.classList.add("hidden");
    }
  }

  search(e) {
    let el = e.target
    while ('BUTTON' !== el.nodeName) {
      el = el.parentElement;
    }
    while ('INPUT' !== el.nodeName) {
      el = el.previousSibling;
    }
    const input = el;
    // const list = document.querySelector(`#${input.getAttribute("list")}`);
    const value = input.value.toLowerCase();
    let div_id = input.getAttribute("data-div-id");
    let url = input.getAttribute("data-url");
    url += `?q=${value}&div_id=${div_id}`;

    fetch(url)
    .then((r) => r.text())
    .then(html => Turbo.renderStreamMessage(html))

    this.optionsIconTarget.classList.remove("hidden");
    this.searchIconTarget.classList.add("hidden");

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
