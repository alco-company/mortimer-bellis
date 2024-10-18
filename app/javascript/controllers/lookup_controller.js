import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lookup"
export default class extends Controller {
  static targets = [
    "input",
    "item",             // the li element
    "selectId",         // the hidden input element
    "lookupOptions",    // the div element containing the Ul element
    "optionsList",      // the Ul element
    "searchIcon",
    "optionsIcon"
  ]

  items_connected = false;

  connect() {
    console.log("Connected to lookup controller")
    this.inputTarget.addEventListener("input", this.change.bind(this));
  }

  async itemTargetConnected(e) {
    if (!this.items_connected) {
      this.items_connected = true;
      await new Promise(r => setTimeout(r, 50));
      this.optionsIconTarget.classList.remove("hidden");
      this.searchIconTarget.classList.add("hidden");
      this.optionsListTarget.getElementsByTagName("LI")[0].focus();
    }
  }

  key_down(e) {
    switch(e.key) {
      case "Escape": e.stopPropagation(); this.toggleOptions(e); break;
      case "ArrowDown": e.stopPropagation(); this.searchIconTarget.click(); break;
      default: console.log(`you pressed ${e.key}`);
    }
  }

  optionsKeydown(e) {
    e.stopPropagation();
    // console.log(`you pressed ${e.key} on a li item`);
    switch(e.key) {
      case "Escape": this.toggleOptions(e); this.inputTarget.focus(); break;
      case "ArrowDown": this.focusNextItem(e); break;
      case "ArrowUp": this.focusPreviousItem(e); break;
      case "Enter": this.toggleOptions(e); this.select_option(e); break;
      case " ": this.toggleOptions(e); this.select_option(e); break;
      default: console.log(`you pressed ${e.key}`);
    }
  }

  select_option(e) {
    let el = e.target;
    while ('LI' !== el.nodeName) {
      el = el.parentElement;
    }
    this.inputTarget.value = el.dataset.displayValue;
    this.selectIdTarget.value = el.dataset.value;
    this.optionsIconTarget.classList.remove("hidden");
    this.searchIconTarget.classList.add("hidden");

    el.closest("UL").querySelectorAll("LI > SPAN > SVG").forEach((e) => {
      e.parentElement.classList.add("hidden");
    });
    el.querySelectorAll("LI > SPAN > SVG").forEach((e) => {
      e.parentElement.classList.remove("hidden");
    })
    el.closest("DIV").classList.add("hidden");
  }

  change(e) {
    if (this.searchIconTarget.classList.contains("hidden")) {
      this.optionsIconTarget.classList.add("hidden");
      this.searchIconTarget.classList.remove("hidden");
      this.items_connected = false;
    }
  }

  toggleOptions(e) {
    const options = this.lookupOptionsTarget;
    if (options.classList.contains("hidden")) {
      options.classList.remove("hidden");
      this.items_connected = true;
      this.optionsListTarget.getElementsByTagName("LI")[0].focus();
    } else {
      options.classList.add("hidden");
      this.items_connected = false;
    }
  }

  search(e) {
    let el = e.target
    this.items_connected = false;
    if (el.nodeName != "INPUT") {
      while ('BUTTON' !== el.nodeName) {
        el = el.parentElement;
      }
      while ('INPUT' !== el.nodeName) {
        el = el.previousSibling;
      }
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
  }

  focusNextItem(e) {
    e.target.nextElementSibling.focus();
  }

  focusPreviousItem(e) {
    e.target.previousElementSibling.focus();
  }
}
