import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-material"
export default class extends Controller {
  static targets = [
    "invoice"
  ]

  connect() {
    console.log("Connected to time-material controller")
  }

  customerChange(e) {
    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
      this.invoiceTarget.checked = false;
    } else {
      this.invoiceTarget.checked = true;
    }
  }

  projectChange(e) {
    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
    }
  }

  productChange(e) {
    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
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


}
