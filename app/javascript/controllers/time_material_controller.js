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
    "mileage",
    "listlabel"
  ]

  static values = {
    time: Number,
    interval: 1000,
    reload: 60000,
    products: Array
  }

  hourRate = 0.0;
  initialCustomer = "";
  initialProject = "";

  initialize() {
    this.interval = null;
    this.reload = null;
  }

  connect() {
    let tmr = document.getElementById("time_material_rate");
    this.token = document.querySelector('meta[name="csrf-token"]').content;
    if (tmr) 
      this.hourRate = document.getElementById("time_material_rate").value;
    try {      
      if (this.counterTarget.dataset.state == "active") {
        this.startTimer();
      }
    } catch (error) {      
    }
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
    this.reload = setInterval(() => {
      console.log(` reload: ${this.listlabelTarget.dataset.reloadUrl}`);
      fetch(this.listlabelTarget.dataset.reloadUrl, {
        method: "GET",
        headers: {
          "X-CSRF-Token": this.token,
          "Content-Type": "text/vnd.turbo.stream.html",
        },
      });
    }, this.reloadValue);
  }
  

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
    if (this.reload) {
      clearInterval(this.reload);
      this.reload = null;
    }
  }

  updateOverTime(e) {
    let elem = document.getElementById("time_material_over_time");
    if (this.productsValue.length >= elem.value) {
      document.getElementById("time_material_rate").value =
        this.hourRate * (this.productsValue[ elem.value ] / this.productsValue[0] );
    }
  }

  rateChange(e) {
    // if (e.currentTarget.value != this.hourRate) {
    //   this.hourRate = e.currentTarget.value;
    // }
  }

  customerChange(e) {
    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
      if (this.invoiceTarget.value == 1)
        this.invoiceTarget.nextElementSibling.click();
    } else {
      if (this.invoiceTarget.value == 0)
        this.invoiceTarget.nextElementSibling.click();
      if ( document.querySelector("#time_material_customer_id").dataset.lookupCustomerHourlyRate ) {
        if (document.querySelector("#time_material_customer_id").value !== this.initialCustomer) {
          this.initialCustomer = document.querySelector("#time_material_customer_id").value;
          let tmr = document.getElementById("time_material_rate");
          tmr.value = this.empty_value(
            tmr,
            document.querySelector("#time_material_customer_id").dataset
              .lookupCustomerHourlyRate
          );
          this.updateOverTime(document.getElementById("time_material_over_time"));
        }
      }
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
      if ( document.querySelector("#time_material_project_id").dataset.lookupProjectHourlyRate ) {
        if (document.querySelector("#time_material_project_id").value !== this.initialProject) {
          this.initialProject = document.querySelector("#time_material_project_id").value;
          let tmr = document.getElementById("time_material_rate");
          tmr.value = this.empty_value( tmr, document.querySelector("#time_material_project_id").dataset.lookupProjectHourlyRate);
          this.updateOverTime( document.getElementById("time_material_over_time") );
        }        
      }
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

  empty_value(e, value = 0.0) {
    console.log(`hourRate: ${this.hourRate}`);
    if (
      e.value === "" ||
      e.value == 0 ||
      e.value == "0,0" ||
      e.value == this.hourRate && 
      value != 0.0
    ) {
      this.hourRate = value;
      console.log(`hourRate updated: ${this.hourRate}`);
      return value;
    }
    return e.value
  }


}
