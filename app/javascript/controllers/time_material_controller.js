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
    products: Array,
    syncUrl: String,
    changeStateUrl: String
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
    this.startedAtMs = null; // ms epoch when the current active stint began
  }

  connect() {
    try {
      this.state = this.itemTarget.dataset.state;
      this.playerId = this.itemTarget.id;
      this.token = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
      this.setVersion( parseInt(this.itemTarget.dataset.timeMaterialVersionValue, 10) );
      this.setTimerOnState();
      window.addEventListener( "online", (this.flushQueueBound = () => this.flushQueue()) );
      document.addEventListener("visibilitychange", this.onVisibilityChange);
    } catch (e) {
      console.error("Error connecting TimeMaterialController:", e);
    }
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.onVisibilityChange);
    document.removeEventListener("online", this.flushQueueBound);
    this.stopTimer();
  }

  // Handle visibility change events ------------------------------------------

  onVisibilityChange = () => {
    if (document.visibilityState === "visible") this.flushQueue();
    if (document.visibilityState === "visible" && this.state === "active" && this.startedAtMs) {
      // instant catch-up render
      this.timeValue = Math.floor((Date.now() - this.startedAtMs) / 1000);
      this.render();
    }
  };  

  // Timer --------------------------------------------------------------------

  setTimerOnState() {
    switch (this.state) {
      case "resume":
        this.state = "active";
        this.lastSyncAt = Date.now();
        this.timeValue = parseInt(this.counterTarget.dataset.counter, 10) || 0;
        this.setStartedAt();
        this.persistTimingState();
        this.startTimer();
        break;
      case "active":
        this.lastSyncAt = Date.now();
        this.timeValue = parseInt(this.counterTarget.dataset.counter, 10) || 0;
        this.persistTimingState();
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

    // If we don't have a startedAtMs yet, derive it from current wall time minus accumulated seconds
    if (!this.startedAtMs) {
      this.startedAtMs = Date.now() - (this.timeValue || 0) * 1000;
    }

    // Do an immediate render and schedule next tick
    this.tick();
  }

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
    // Lock in the final elapsed value at stop/pause time
    this.moveHand();
    this.startedAtMs = null;
    this.persistTimingState();
  }

  tick() {
    this.moveHand();
    this.render();

    if (this.shouldReloadTimingStateFromServer())
      this.syncStateWithServer();
      // this.reloadTimingStateFromServer();

    this.next_tick();
  }

  moveHand() {
    // Derive from wall clock so background throttling doesn’t matter
    if (this.state === "active" && this.startedAtMs) {
      this.timeValue = Math.max(
        0,
        Math.floor((Date.now() - this.startedAtMs) / 1000)
      );
    }
  }

  setStartedAt() {
    this.startedAtMs = Date.now() - (this.timeValue || 0) * 1000;
  }

  next_tick() {
    // Schedule next tick exactly at next whole second boundary
    const msToNextSecond = 1000 - (Date.now() % 1000);
    this.interval = setTimeout(() => this.tick(), msToNextSecond);
  }

  shouldReloadTimingStateFromServer() {
    return !this.inflightReload &&
    this.state === "active" &&
    navigator.onLine &&
    !document.hidden &&
    (this.lastSyncAt === null ||
      Date.now() - this.lastSyncAt >= this.reloadValue)
  }

  checkInLater() {
    if (!navigator.onLine) {
      setTimeout(() => this.checkInLater(), 15000);
      console.log(`offline - will check in later, ${this.playerId} - ${this.state} - ${this.timeValue}`);
      return;
    }
    this.flushQueue();
    this.setTimerOnState();
  }

  loadTimingState() {
    try {
      const raw = JSON.parse(
        localStorage.getItem(this.playerId + ":timing") || "{}"
      );
      this.timeValue = Number.isFinite(raw.timeValue) ? raw.timeValue : 0;
      this.state = raw.state || "active";
      this.startedAtMs = Number.isFinite(raw.startedAtMs) ? raw.startedAtMs : null;
    } catch {
      this.timeValue = 0;
      this.state = "active";
      this.startedAtMs = null;
    }
    try {
      let value = parseInt(this.counterTarget.dataset.counter, 10) || 0;
      if (Math.abs(value - this.timeValue) > 30) {
        this.timeValue = value;
        if (this.state === "active") {
          this.startedAtMs = Date.now() - this.timeValue * 1000;
        }
      }
    } catch {}
  }

  persistTimingState() {
    try {
      localStorage.setItem(
        this.playerId + ":timing",
        JSON.stringify({
          timeValue: this.timeValue,
          state: this.state,
          startedAtMs: this.startedAtMs
        })
      );
    } catch {}
  }

  // Server Dialogue ---------------------------------------------------------
  
  async syncStateWithServer() {
    if (this.state === "active" && navigator.onLine) {
      try {
        const body = {
          ops: [ { type: "sync", at_ms: Date.now() } ],
          version: this.getVersion(), // optimistic lock
        };
        // try empty the queue first
        this.flushQueue()
        .then(async (r) => r)
        .then(() => { 
          this.flushQueue(body); 
        })

      } catch (error) {
        console.error("Error syncing state with server:", error);
      }
    }
  }

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
      this.lastSyncAt = Date.now();
      this.flushQueue();
    })
    .catch((e) => {
      // could not reloadTimingStateFromServer
      // will continue ticking locally
      this.checkInLater();
      this.setTimerOnState();
      if (url.match(/(\?|&)pause=stop/)) {
        this.state = "stopped";
      } else {
        if (url.match(/(\?|&)pause=paused/)) {
          this.state = "paused";
        } else {
          if (url.match(/(\?|&)pause=resume/)) {
            this.state = "resume";
          }
        }
      }
      this.handleOffline();
    })
    .finally(() => { 
      this.inflightReload = false; 
    });
  }

  // Queue helpers ------------------------------------------------------------
  
  queueKey() { return this.playerId + ":ops"; }
  versionKey() { return this.playerId + ":version"; }

  readQueue() {
    try { return JSON.parse(localStorage.getItem(this.queueKey()) || "[]"); } catch { return []; }
  }
  saveQueue(arr) {
    try { localStorage.setItem(this.queueKey(), JSON.stringify(arr)); } catch {}
  }
  pushOp(op) {
    // ensure stable id for dedupe on retries
    const withId = { id: crypto.randomUUID(), ...op };
    const arr = this.readQueue();
    arr.push(withId);
    this.saveQueue(arr);
    return withId;
  }
  getVersion() {
    const v = parseInt(localStorage.getItem(this.versionKey()), 10);
    return Number.isFinite(v) ? v : null;
  }
  setVersion(v) {
    if (Number.isFinite(v)) localStorage.setItem(this.versionKey(), String(v));
  }

  // when user hits Resume while offline
  enqueueResume() {
    // startedAtMs must reflect when work resumed
    if (!this.startedAtMs) this.startedAtMs = Date.now() - (this.timeValue || 0) * 1000;
    this.pushOp({ type: "resume", at_ms: Date.now() });
  }

  // when user hits Pause while offline
  enqueuePause() {
    if (this.startedAtMs) {
      const deltaSec = Math.max(0, Math.floor((Date.now() - this.startedAtMs) / 1000));
      this.startedAtMs = null;
      this.pushOp({ type: "pause_delta", delta_sec: deltaSec });
    }
  }

  // when user hits Stop while offline
  enqueueStop() {
    this.pushOp({ type: "stop", at_ms: Date.now() });
    this.startedAtMs = null;
  }

  async flushQueue(body = null, url = this.syncUrlValue, headers = { "Content-Type": "application/json", "X-CSRF-Token": this.token }) {
    if (!navigator.onLine) return;
    if (!url) return;

    let ops = []
    let batch = [];
    if (!body) {

      ops = this.readQueue();
      if (ops.length === 0) return;
  
  
      // Send a small batch to reduce risk (e.g. 25 ops at a time)
      batch = ops.slice(0, 25);
      body = {
        ops: batch,
        version: this.getVersion() // optimistic lock
      };
    }

    let resp;
    try {
      resp = await fetch(url, {
        method: "POST",
        headers: headers,
        body: JSON.stringify(body)
      });
    } catch {
      // network error; keep queue and back off silently
      if (batch.length < 1) this.handleOffline();
      return;
    }
    
    if (resp.status === 409) {
      // Version conflict. Server returns current snapshot; replace local state.
      const snapshot = await resp.json();
      this.reconcileFromSnapshot(snapshot);
      // IMPORTANT: drop whole queue since server state won
      this.saveQueue([]);
      return;
    }
    
    if (!resp.ok) {
      // 5xx or 422 – leave queue and try again later
      return;
    }
    
    // Success: server returns fresh snapshot with new lock_version
    if (url.match(/turbo/)){
      const html = await resp.text();
      Turbo.renderStreamMessage(html);
      this.lastSyncAt = Date.now();
      this.flushQueue();
    } else {
      const snapshot = await resp.json();
      this.reconcileFromSnapshot(snapshot);
  
      // Remove the batch we sent successfully and keep flushing until empty
      const remaining = ops.slice(batch.length);
      this.saveQueue(remaining);
  
      // Tail recursion-ish: try again quickly while online
      if (remaining.length > 0) {
        // small delay to avoid tight loop
        setTimeout(() => this.flushQueue(), 50);
      }
    }
  }

  reconcileFromSnapshot(s) {
    // s: { id, state, total_seconds, registered_minutes, started_at, version }
    this.setVersion(s.version);
    this.timeValue = s.total_seconds ?? this.timeValue;
    this.counterTarget.dataset.counter = this.timeValue;
    this.state = s.state ?? this.state;
    this.startedAtMs = s.started_at ? Date.parse(s.started_at) : null;
    this.persistTimingState();
    this.render();
    this.setTimerOnState(); // start/stop local tickers to match state
  }

  handleOffline() {
    switch (this.state) {
      case "resume":
        this.state = "active";
        if (!this.startedAtMs)
          this.startedAtMs = Date.now() - (this.timeValue || 0) * 1000;
        this.startTimer();
        this.pausebuttonTarget.classList.remove("hidden");
        this.resumebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.remove("hidden");
        this.enqueueResume();
        break;
      case "paused":
        if (this.startedAtMs) {
          this.timeValue = Math.floor((Date.now() - this.startedAtMs) / 1000);
          this.startedAtMs = null;
        }
        this.stopTimer();
        this.pausebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        this.enqueuePause();
        break;
      case "stopped":
        if (this.startedAtMs) {
          this.timeValue = Math.floor((Date.now() - this.startedAtMs) / 1000);
          this.startedAtMs = null;
        }
        this.stopTimer();
        this.activelampTarget.classList.add("hidden");
        this.pausebuttonTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        this.enqueueStop();
        break;
    }
    this.persistTimingState();
    this.checkInLater();
  }

  // Actions ------------------------------------------------------------------

  changeState(e){
    this.state = e.target.dataset.state;
    if (navigator.onLine) {
      const body = {
        ops: [{ type: this.state, at_ms: Date.now() }],
        version: this.getVersion()
      };
      const headers = {
        "X-CSRF-Token": this.token,
      };
      const url = this.changeStateUrlValue;
      this.flushQueue(body, url);
    } else {
      this.handleOffline();
    }
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
    // console.log(`hourRate: ${this.hourRate}`);
    if (
      e.value === "" ||
      e.value == 0 ||
      e.value == "0,0" ||
      e.value == this.hourRate && 
      value != 0.0
    ) {
      this.hourRate = value;
      // console.log(`hourRate updated: ${this.hourRate}`);
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
    }
  }
}
