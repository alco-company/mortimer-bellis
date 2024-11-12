import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-material"
export default class extends Controller {
  static targets = [
    "invoice",
    "timetab",
    "materialtab",
    "counter",
    "odofrom",
    "odoto",
    "mileage"
  ]

  connect() {
    try {      
      if (this.counterTarget) {
        this.startTimer();
      }
    } catch (error) {
      
    }
  }

  startTimer() {
    setInterval(() => {
      this.counterTarget.dataset.counter = parseInt(this.counterTarget.dataset.counter) + 1;
      let hours = Math.floor(this.counterTarget.dataset.counter / 3600);
      let minuts = Math.floor((this.counterTarget.dataset.counter - (hours * 3600)) / 60);
      let sec = Math.floor(this.counterTarget.dataset.counter - (hours * 3600) - (minuts * 60));
      this.counterTarget.innerText = hours.toString().padStart(2, "0") + ":" + minuts.toString().padStart(2, "0") + ":" + sec.toString().padStart(2, "0");
    }, 1000);
  }

  customerChange(e) {
    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
      if (this.invoiceTarget.value == 1)
        this.invoiceTarget.nextElementSibling.click();
    } else {
      if (this.invoiceTarget.value == 0)
        this.invoiceTarget.nextElementSibling.click();
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

  setMileage(e) {
    this.mileageTarget.value =
      this.odotoTarget.value - this.odofromTarget.value;
  }


}
