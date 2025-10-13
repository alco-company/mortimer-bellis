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
    this.inflightReload = false;
    this.reload = null;
    this.state = null;
    this.opQueue = []; // offline ops
    // this.lastSyncAt = 0;
  }

  connect() {
    try {
      // this.playerId = this.itemTarget.id;
      // let tmr = document.getElementById("time_material_rate");
      // this.token = document.querySelector('meta[name="csrf-token"]').content;
      // if (tmr)
      //   this.hourRate = document.getElementById("time_material_rate").value;
      // this.loadTimingState();
      this.stopTimer();
      // sane defaults if not provided
      this.intervalValue ||= 1000;
      this.reloadValue ||= 60000;

      // start ticking only when active
      const state = this.itemTarget?.dataset?.state;
      if (state === "active") this.startTimer();

      // throttle reloads in background tabs
      this._onVisibility = () => {
        if (document.hidden) this.lastSyncAt = Date.now();
      };
      document.addEventListener("visibilitychange", this._onVisibility);
      this.playerId = this.itemTarget.id;
      this.token = document.querySelector('meta[name="csrf-token"]').content;
      this.loadTimingState();
      window.addEventListener("online", this.flushQueue);
    } catch (e) {
      // console.error(`Error initializing TimeMaterialController ${this.playerId || 'hmm'} `);
    }
  }

  disconnect() {
    this.stopTimer();
    this.persistTimingState();
    document.removeEventListener("visibilitychange", this._onVisibility);
    this._onVisibility = null;
    // this.playerId = null;
    window.removeEventListener("online", this.flushQueue);
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

  readQueue() {
    try { return JSON.parse(localStorage.getItem(this.playerId + ":ops") || "[]"); } catch { return []; }
  }
  clearQueue() {
    try { localStorage.removeItem(this.playerId + ":ops"); } catch {}
  }

  flushQueue = () => {
    if (!navigator.onLine) return;
    const ops = this.readQueue();
    if (ops.length === 0) return;

    fetch(`/time_materials/${this.playerId}/sync`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ ops: ops, version: parseInt(this.itemTarget.dataset.version || "0", 10) })
    })
    .then(r => {
      if (r.status === 409) return r.json().then(snap => { this.applySnapshot(snap); this.clearQueue(); });
      if (!r.ok) throw new Error("sync failed");
      return r.json();
    })
    .then(snap => { if (snap) { this.applySnapshot(snap); this.clearQueue(); } })
    .catch(() => { /* keep queue for later */ });
  }

  applySnapshot(snap) {
    // Rebase local timer to server truth
    const wasActive = snap.started_at != null && snap.state === "active";
    this.baseSeconds = snap.total_seconds - (wasActive ? Math.floor((Date.now() - Date.parse(snap.started_at)) / 1000) : 0);
    if (this.baseSeconds < 0) this.baseSeconds = 0;
    this.startedAtMs = wasActive ? Date.now() : null;
    this.itemTarget.dataset.state = snap.state;
    this.itemTarget.dataset.version = snap.version;
    this.timeValue = this.baseSeconds + (wasActive ? Math.floor((Date.now() - this.startedAtMs) / 1000) : 0);
    if (wasActive) this.startTimer(); else this.stopTimer();
    this.persistTimingState();
    this.render();
  }

  // Actions ------------------------------------------------------------------

  changeState(e){
    this.state = e.target.dataset.icon;
    let url = this.listlabelTarget.dataset.url;
    this.pauseTimer();
    if (this.state == "stop") url = url.replace(/\?pause\=.*$/, "?pause=stop");
    this.reloadFromServer(url);
  }

  reloadFromServer(url) {
    this.inflightReload = true
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
      this.state = this.itemTarget.dataset.state;
      this.timeValue = parseInt(this.counterTarget.dataset.counter, 10);
      this.startedAtMs = null;
      this.baseSeconds = this.timeValue;
      switch (this.state) {
        case "active":
          this.resumeTimer();
          break;
        case "paused":
          this.pauseTimer();
          break;
        case "stopped":
          this.stopTimer();
          this.baseSeconds = 0;
          this.startedAtMs = null;
          this.timeValue = 0;
          this.persistTimingState();
          break;
      }
      this.flushQueue(); // try to push any pending ops after a successful server round-trip
    }).catch((error) => {
      // Offline: queue intent as delta-based operation
      if (this.state === "paused") {
        // we just paused; add the elapsed delta we rolled into baseSeconds
        this.enqueue({ type: "pause_delta", delta_sec: 0, at_ms: Date.now() });
      } else if (this.state === "active") {
        this.enqueue({ type: "resume", at_ms: Date.now() });
      } else if (this.state === "stopped") {
        this.enqueue({ type: "stop", at_ms: Date.now() });
      }
    })
    .finally(() => { this.inflightReload = false; });

        //   switch (this.state) {
        //     case "active":
        //       this.resumeTimer();
        //       break;
        //     case "paused":
        //       this.pauseTimer();
        //       break;
        //     case "stopped":
        //       this.stopTimer();
        //       this.baseSeconds = 0;
        //       this.startedAtMs = null;
        //       this.timeValue = 0;
        //       this.persistTimingState();
        //       break;
        //   }
        // });
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
    this.timeValue = this.baseSeconds;
    try {
      let value = parseInt(this.counterTarget.dataset.counter, 10) || 0;
      if (value > this.timeValue + 30 || value < this.timeValue - 30) {
        this.baseSeconds = value;
        this.startedAtMs = null;
        this.timeValue = this.baseSeconds;
        this.persistTimingState();
      }
    } catch (error) {
    }
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
    const elapsed = Math.floor((now - this.startedAtMs) / 1000);
    this.timeValue = this.baseSeconds + elapsed;
    this.render();

    // Periodic sync based on elapsed time, not modulo (works across sleeps)
    const state = this.itemTarget?.dataset?.state;
    if (
      state === "active" &&
      navigator.onLine &&
      !document.hidden &&
      !this.inflightReload &&
      now - this.lastSyncAt >= this.reloadValue
    ) {
      console.log(`now: ${now}, lastSyncAt: ${this.lastSyncAt}, delta: ${now - this.lastSyncAt}, reloadValue: ${this.reloadValue}`);
      this.lastSyncAt = now;
      this.flushQueue();
      const url = this.listlabelTarget?.dataset?.reloadUrl; // e.g. /time_materials/:id?reload=1
      if (url) this.reloadFromServer(url);
    }

    // Schedule next tick exactly at next whole second boundary
    const msToNextSecond = 1000 - (now % 1000);
    console.log(`Scheduling next tick in ${msToNextSecond} ms`);
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
