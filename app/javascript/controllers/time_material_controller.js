import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-material"
export default class extends Controller {

  // Setup & Teardown ------------------------------------------------------  

  static targets = [
    "invoice",
    "timetab",
    "materialtab",
    "counter",
    "odofrom",
    "odoto",
    "mileage",
    "listlabel",
    "item",
    "pausebutton",
    "resumebutton",
    "activelamp"
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
    // this.interval = null;
    // this.reload = null;
    this.lastSyncAt = Date.now();
    this.inflightReload = false;
    this.state = null;
    this.opQueue = []; // offline ops
  }

  connect() {
    try {
      this.state = this.itemTarget.dataset.state;
      this.playerId = this.itemTarget.id;
      this.setTimerOnState();
    } catch (e) {
      console.error("Error connecting TimeMaterialController:", e);
    }
  }

  disconnect() {
    this.stopTimer();
  }

  // Timer --------------------------------------------------------------------

  setTimerOnState() {
    switch (this.state) {
      case "active":
        this.lastSyncAt = Date.now();
        this.timeValue = parseInt(this.counterTarget.dataset.counter, 10) || 0;
        this.startTimer();
        break;
      case "paused":
        this.stopTimer();
        break;
      case "stopped":
        this.stopTimer();
        break;
    }
  }

  startTimer() {
    if (this.interval) return; // already running
    this.loadTimingState();
    this.tick(); // initial tick
  }

  stopTimer() {
    if (this.interval) {
      this.persistTimingState();
      clearInterval(this.interval);
      this.interval = null;
    }
  }

  tick() {
    const now = Date.now();
    this.timeValue++;
    this.render();
    if (this.shouldReloadTimingStateFromServer()) this.reloadTimingStateFromServer();

    // Schedule next tick exactly at next whole second boundary
    const msToNextSecond = 1000 - (now % 1000);
    this.interval = setTimeout(() => this.tick(), msToNextSecond);
  }

  shouldReloadTimingStateFromServer() {
    return !this.inflightReload &&
    this.state === "active" &&
    navigator.onLine &&
    !document.hidden &&
    !this.inflightReload &&
    (this.lastSyncAt === null ||
      Date.now() - this.lastSyncAt >= this.reloadValue)
  }

  loadTimingState() {
    try {
      const raw = JSON.parse(
        localStorage.getItem(this.playerId + ":timing") || "{}"
      );
      this.timeValue = Number.isFinite(raw.timeValue) ? raw.timeValue : 0;
      this.state = raw.state || null;
    } catch {
      this.timeValue = 0;
      this.state = "active";
    }
    try {
      let value = parseInt(this.counterTarget.dataset.counter, 10) || 0;
      if (value > this.timeValue + 30 || value < this.timeValue - 30) {
        this.timeValue = value;
      }
    } catch (error) {}
  }

  persistTimingState() {
    try {
      localStorage.setItem(
        this.playerId + ":timing",
        JSON.stringify({
          timeValue: this.timeValue,
          state: this.state,
        })
      );
    } catch {}
  }

  // Server Dialogue ---------------------------------------------------------
  
  reloadTimingStateFromServer(url=null) {
    this.inflightReload = true;
    url = url || this.listlabelTarget?.dataset?.reloadUrl; // URL to fetch the latest timing state
    if (!url) {
      this.inflightReload = false;
      return;
    }
    fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "text/vnd.turbo.stream.html",
      },
    })
    .then(async (r) => r.text())
    .then((html) => {
      Turbo.renderStreamMessage(html);
    })
    .catch((e) => {
      // could not reloadTimingStateFromServer
      // will continue ticking locally
      this.setTimerOnState();
      if (url.match(/(\?|&)pause=stop/)) {
        this.state = "stopped";
        this.stopTimer();
      } else {
        if (url.match(/(\?|&)pause=paused/)) {
          this.state = "paused";
          this.stopTimer();
        } else {
          if (url.match(/(\?|&)pause=resume/)) {
            this.state = "active";
            this.startTimer();
          }
        }
      }
      this.enqueue({ time: this.timeValue, state: this.state });
    })
    .finally(() => { 
      this.inflightReload = false; 
      console.log(
        `reloadTimingStateFromServer - minutes: ${this.counterTarget.dataset.counter}, state: ${this.itemTarget.dataset.state}`
      );
    });
  }

  // Queue helpers ------------------------------------------------------------

  enqueue(op) {
    try {
      const key = this.playerId + ":ops";
      const arr = JSON.parse(localStorage.getItem(key) || "[]");
      arr.push(op);
      localStorage.setItem(key, JSON.stringify(arr));
    } catch {}
  }

  // Actions ------------------------------------------------------------------

  changeState(e){
    this.state = e.target.dataset.state;
    let url = this.listlabelTarget.dataset.url;
    this.setTimerOnState();
    if (this.state == "stopped") url = url.replace(/\?pause\=.*$/, "?pause=stop");
    if (navigator.onLine) {
      this.reloadTimingStateFromServer(url);
    } else {
      this.handleOffline();
    }
  }

  handleOffline() {
    switch (this.state) {
      case "resume":
        this.startTimer();
        this.state = "active";
        this.pausebuttonTarget.classList.remove("hidden");
        this.resumebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.remove("hidden");
        break;
      case "paused":
        this.stopTimer();
        this.pausebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        break;
      case "stopped":
        this.stopTimer();
        this.activelampTarget.classList.add("hidden");
        this.pausebuttonTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        break;
    }
    this.enqueue({ time: this.timeValue, state: this.state });
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

  render() {
    const total = this.timeValue || 0;
    const hours = Math.floor(total / 3600);
    const mins  = Math.floor((total % 3600) / 60);
    const secs  = total % 60;
    try {
      this.counterTarget.innerText =
        hours.toString().padStart(2, "0") + ":" +
        mins.toString().padStart(2, "0")
      this.counterTarget.dataset.counter = total;
    } catch (error) {
      // console.error("Error rendering timer - missing this.counterTarget!");
    }
  }
}
