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

  static values = {
    time: Number,
    interval: 1000
  }

  initialize() {
    this.interval = null;
  }

  connect() {
    try {      
      if (this.counterTarget.dataset.state == "active") {
        this.startTimer();
      }
    } catch (error) {
      
    }
    this.token = document.querySelector(
      'meta[name="csrf-token"]'
    ).content;    
  }

  disconnect() {
    this.stopTimer();
  }
  
  tellLoaded(e) {
    console.log(`loaded: ${e.currentTarget}`);
  }

  toggleActive(e){
    this.stopTimer()
    fetch(e.currentTarget.dataset.url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "text/vnd.turbo.stream.html",
      },
    });
    // if (this.interval) {
    //   this.stopTimer();
    //   e.currentTarget.classList.remove("bg-green-200");
    //   e.currentTarget.classList.add("bg-yellow-200");
    // } else {
    //   this.startTimer();
    //   e.currentTarget.classList.remove("bg-yellow-200");
    //   e.currentTarget.classList.add("bg-green-200");
    // }
  }

  startTimer() {
    this.interval = setInterval(() => {
      // if (this.counterTarget.dataset.state == "active") {
      // }
      console.log(this.counterTarget.dataset.state);
      this.timeValue = (parseInt(this.counterTarget.dataset.counter) || this.timeValue) + 1;
      this.counterTarget.dataset.counter = this.timeValue
      let hours = Math.floor(this.timeValue / 3600);
      let minuts = Math.floor((this.timeValue - (hours * 3600)) / 60);
      let sec = Math.floor(this.timeValue - (hours * 3600) - (minuts * 60));
      this.counterTarget.innerText = hours.toString().padStart(2, "0") + ":" + minuts.toString().padStart(2, "0") + ":" + sec.toString().padStart(2, "0");
    }, this.intervalValue);
  }

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
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
      return
    }
    
    if (document.querySelector("#time_material_project_id").dataset.lookupCustomerName) {
      document.querySelector("#time_material_customer_id").value =
      document.querySelector(
        "#time_material_project_id"
      ).dataset.lookupCustomerId;
      document.querySelector("#time_material_customer_name").value =
      document.querySelector(
        "#time_material_project_id"
      ).dataset.lookupCustomerName;
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
