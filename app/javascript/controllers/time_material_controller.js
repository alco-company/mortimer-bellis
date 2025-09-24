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
    "listlabel",
    "item"
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
    try {
      this.playerId = this.itemTarget.id;
      let tmr = document.getElementById("time_material_rate");
      this.token = document.querySelector('meta[name="csrf-token"]').content;
      if (tmr)
        this.hourRate = document.getElementById("time_material_rate").value;
      this.loadTimingState();
    } catch (e) {
      console.error(`Error initializing TimeMaterialController ${this.playerId || 'hmm'} `);
    }
  }

  disconnect() {
    this.stopTimer();
    this.persistTimingState();
  }

  clickIcon(e){
    let icon = e.target.closest("SVG").dataset.icon;
    let url = this.listlabelTarget.dataset.url;
    this.pauseTimer()
    if (icon == "stop") {
      url = url.replace(/\?pause\=.*$/, "?pause=stop");
    }
    fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "text/vnd.turbo.stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => {
        icon == "play" ? this.resumeTimer() : this.pauseTimer();
        Turbo.renderStreamMessage(html)
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

  updateOverTime(e) {
    let elem = document.getElementById("time_material_over_time");
    if (this.productsValue.length >= elem.value) {
      document.getElementById("time_material_rate").value =
        this.hourRate * (this.productsValue[ elem.value ] / this.productsValue[0] );
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

  pauseResumeStop(e) {
    alert(e)
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
    // this.mileageTarget.value =
    //   this.odotoTarget.value - this.odofromTarget.value;
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

  // Timer related functions ----------------------------------

  loadTimingState() {
    try {
      const raw = JSON.parse(localStorage.getItem(this.playerId + ":timing") || "{}");
      this.baseSeconds = (Number.isFinite(raw.baseSeconds) ? raw.baseSeconds : 0);
      this.startedAtMs = raw.startedAtMs || null;
    } catch {
      this.baseSeconds = 0;
      this.startedAtMs = null;
    }
    try {
      let value = parseInt(this.counterTarget.dataset.counter, 10) || 0;
      if (value > this.timeValue + 30) {
        this.baseSeconds = value;
        this.startedAtMs = null;
        this.persistTimingState();
      }
    } catch (error) {
    }
    this.timeValue = this.baseSeconds;
    try {
      if (this.counterTarget.dataset.state === "active") {
        this.startTimer();
      }

    } catch(e) {
    }
  }

  persistTimingState() {
    try {
      localStorage.setItem(
        this.playerId + ":timing",
        JSON.stringify({ baseSeconds: this.baseSeconds, startedAtMs: this.startedAtMs })
      );
    } catch {}
  }

  startTimer() {
    if (!this.startedAtMs) {
      this.startedAtMs = Date.now();
      this.persistTimingState();
    }
    if (this.interval) return;
    this.tick(); // immediate update
  }

  stopTimer() {
    if (this.interval) {
      clearTimeout(this.interval);
      this.interval = null;
    }
  }

  // Call this when user hits “pause/stop” (after server confirms if needed)
  pauseTimer() {
    if (this.startedAtMs) {
      const now = Date.now();
      const elapsed = Math.floor((now - this.startedAtMs) / 1000);
      this.baseSeconds += elapsed;
      this.startedAtMs = null;
      this.timeValue = this.baseSeconds;
      this.persistTimingState();
      this.render();
    }
    this.stopTimer();
  }

  // Call this on “resume” (after server confirms)
  resumeTimer() {
    if (!this.startedAtMs) {
      this.startedAtMs = Date.now();
      this.persistTimingState();
      this.startTimer();
    }
  }


  tick() {
    if (!this.startedAtMs) return; // paused
    const now = Date.now();
    const elapsed = Math.floor((now - this.startedAtMs) / this.intervalValue);
    this.timeValue = this.baseSeconds + elapsed;
    this.render();

    // Schedule next tick exactly at next whole second boundary
    const msToNextSecond = this.intervalValue - (now % this.intervalValue);
    this.interval = setTimeout(() => this.tick(), msToNextSecond);
  }

  render() {
    const total = this.timeValue || 0;
    const hours = Math.floor(total / 3600);
    const mins  = Math.floor((total % 3600) / 60);
    const secs  = total % 60;
    try {
      this.counterTarget.innerText =
        hours.toString().padStart(2, "0") + ":" +
        mins.toString().padStart(2, "0") + ":" +
        secs.toString().padStart(2, "0");
      this.counterTarget.dataset.counter = total;
    } catch (error) {
      // console.error("Error rendering timer - missing this.counterTarget!");
    }
  }
}
