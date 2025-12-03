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
    // console.log(`initializing...`);
    // this.interval = null;
    // this.reload = null;
    this.lastSyncAt = Date.now();
    this.inflightReload = false;
    this.state = null;
    this.startedAtMs = null; // ms epoch when the current active stint began
  }

  connect() {
    // console.log(`connecting...`);
    // if (this.itemTarget.dataset.form) return;
    try {
      this.state = this.itemTarget.dataset.state;
      this.playerId = this.itemTarget.id;
      this.token = document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content");
      this.setVersion(
        parseInt(this.itemTarget.dataset.timeMaterialVersionValue, 10)
      );
      this.setTimerOnState();
      this.initialCustomer = document.querySelector(
        "#time_material_customer_id"
      ).value;
      this.hourRate =
        parseFloat(document.getElementById("time_material_rate").value) || 0.0;
      this.initialProject = document.querySelector(
        "#time_material_project_id"
      ).value;
      if (
        this.state === "active" ||
        this.state === "resume" ||
        this.state === "stopped" ||
        this.state === "paused"
      ) {
        window.addEventListener(
          "online",
          (this.flushQueueBound = () => this.flushQueue())
        );
        document.addEventListener("visibilitychange", this.onVisibilityChange);
      }
    } catch (e) {
      console.error("Error connecting TimeMaterialController:", e);
    }
    // console.log(`connected: ${this.playerId} - ${this.state} - ${this.timeValue} - ${this.hourRate}`);
  }

  disconnect() {
    if (this.itemTarget.dataset.form) return;

    // console.log(`disconnecting this ${this.playerId} - ${this.state} - ${this.timeValue}`);
    this.stopTimer();
    document.removeEventListener("visibilitychange", this.onVisibilityChange);
    document.removeEventListener("online", this.flushQueueBound);
  }

  // Handle visibility change events ------------------------------------------

  onVisibilityChange = () => {
    // console.log(`visibility change: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    if (document.visibilityState === "visible") this.flushQueue();
    // if (document.visibilityState === "visible" && this.state === "active" && this.startedAtMs) {
    //   // instant catch-up render
    //   this.timeValue = this.getTimeValue();
    //   this.render();
    // }
  };  

  // Timer --------------------------------------------------------------------

  setTimerOnState() {
    // console.log(`setting timer on state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    switch (this.state) {
      case "resume":
        this.state = "active";
        // this.lastSyncAt = Date.now();
        this.timeValue = parseInt(this.counterTarget.dataset.counter, 10) || 0;
        this.setStartedAtMs();
        this.persistTimingState();
        this.startTimer();
        break;
      case "active":
        // this.lastSyncAt = Date.now();
        this.timeValue = parseInt(this.counterTarget.dataset.counter, 10) || 0;
        this.setStartedAtMs();
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
    // console.log(`starting timer: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    if (this.interval) return; // already running
    this.loadTimingState();
    this.state = "active";

    // If we don't have a startedAtMs yet, derive it from current wall time minus accumulated seconds
    if (!this.startedAtMs) {
      this.startedAtMs = this.getStartedAtMs();
    }

    // Do an immediate render and schedule next tick
    this.tick();
  }

  stopTimer() {
    // console.log(`stopping timer: ${this.playerId} - ${this.state} - ${this.timeValue}`);
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
    // console.log(`ticking: ${this.playerId} - ${this.state} - ${this.timeValue}`);
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
        this.getTimeValue()
      );
    }
  }

  setItemDatasetCounter() {
    try {
      this.counterTarget.dataset.counter = this.timeValue;
    } catch (error) {
    }
  }

  setStartedAtMs() {
    this.startedAtMs = Date.now() - (this.timeValue || 0) * 1000;
  }

  getStartedAtMs() {
    return Date.now() - (this.timeValue || 0) * 1000;
  }

  getTimeValue() {
    if (!this.startedAtMs) this.startedAtMs = this.timeValue || Date.now();
    return Math.floor((Date.now() - this.startedAtMs) / 1000);
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
      // console.log(`offline - will check in later, ${this.playerId} - ${this.state} - ${this.timeValue}`);
      return;
    }
    this.flushQueue();
  }

  loadTimingState() {
    // console.log(`loading timing state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
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
          this.setStartedAtMs();
        }
      }
    } catch {}
    // console.log(
    //   `loaded timing state: ${this.playerId} - ${this.state} - ${this.timeValue} - ${this.startedAtMs}`
    // );
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
    // console.log(`persisted timing state: ${this.playerId} - ${this.state} - ${this.timeValue} - ${this.startedAtMs}`);
  }

  // Server Dialogue ---------------------------------------------------------
  
  async syncStateWithServer() {
    // console.log(`syncing timing state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    if (this.state === "active" && navigator.onLine && !this.inflightReload) {
      try {
        const body = {
          ops: [ { type: "sync", at_ms: Date.now() } ],
          version: this.getVersion(), // optimistic lock
        };
        // try empty the queue first
        this.flushQueue()
        .then(async (r) => r)
        .then(() => { 
          this.flushQueue(body)
        })

      } catch (error) {
        console.error("Error syncing state with server:", error);
      } finally {
        this.inflightReload = false;
      }
    }
    // console.log(
    //   `synced timing state: ${this.playerId} - ${this.state} - ${this.timeValue}`
    // );

  }

  // reloadTimingStateFromServer(url=null) {
  //   this.inflightReload = true;
  //   url = url || this.listlabelTarget?.dataset?.reloadUrl; // URL to fetch the latest timing state
  //   if (!url) {
  //     this.inflightReload = false;
  //     return;
  //   }
  //   fetch(url, {
  //     method: "GET",
  //     headers: {
  //       "X-CSRF-Token": this.token,
  //       "Content-Type": "text/vnd.turbo.stream.html",
  //     },
  //   })
  //   .then(async (r) => r.text())
  //   .then((html) => {
  //     Turbo.renderStreamMessage(html);
  //     this.lastSyncAt = Date.now();
  //     this.flushQueue();
  //   })
  //   .catch((e) => {
  //     // could not reloadTimingStateFromServer
  //     // will continue ticking locally
  //     this.checkInLater();
  //     this.setTimerOnState();
  //     if (url.match(/(\?|&)pause=stop/)) {
  //       this.state = "stopped";
  //     } else {
  //       if (url.match(/(\?|&)pause=paused/)) {
  //         this.state = "paused";
  //       } else {
  //         if (url.match(/(\?|&)pause=resume/)) {
  //           this.state = "resume";
  //         }
  //       }
  //     }
  //     this.handleOffline();
  //   })
  //   .finally(() => { 
  //     this.inflightReload = false; 
  //   });
  // }

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

  // when user hits Start while offline
  enqueueStart() {
    // startedAtMs must reflect when work resumed
    if (!this.startedAtMs) this.setStartedAtMs();
    this.pushOp({ type: "start", at_ms: Date.now() });
  }

  // when user hits Resume while offline
  enqueueResume() {
    // startedAtMs must reflect when work resumed
    if (!this.startedAtMs) this.setStartedAtMs();
    this.pushOp({ type: "resume", at_ms: Date.now() });
  }

  // when user hits Pause while offline
  enqueuePause() {
    if (this.startedAtMs) {
      const deltaSec = Math.max(0, this.getTimeValue());
      this.pushOp({ type: "pause_delta", delta_sec: deltaSec });
    }
  }

  // when user hits Stop while offline
  enqueueStop() {
    this.pushOp({ type: "stop", at_ms: Date.now() });
  }

  async flushQueue(body = null, url = this.syncUrlValue, headers = { "Content-Type": "application/json", "X-CSRF-Token": this.token }) {
    // console.log(`flushing queue: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    if (!navigator.onLine) return;
    if (!url) return;
    if (this.inflightReload) return;

    let ops = []
    let batch = [];
    if (!body) {

      ops = this.readQueue();
      // console.log(`ops to flush: ${ops.length} items`);
      if (ops.length === 0) return; //{
      //   ops = [ { type: "sync", at_ms: Date.now() } ]
      // }
  
      // Send a small batch to reduce risk (e.g. 25 ops at a time)
      batch = ops.slice(0, 25);
      body = {
        ops: batch,
        version: this.getVersion() // optimistic lock
      };
    }

    let resp;
    try {
      this.inflightReload = true;

      resp = await fetch(url, {
        method: "POST",
        headers: headers,
        body: JSON.stringify(body)
      });
    } catch {
      // network error; keep queue and back off silently
      this.inflightReload = false;
      if (batch.length < 1) this.handleOffline();
      return;
    } finally {
      this.inflightReload = false;
    }

    if (resp.status === 409) {
      // Version conflict. Server returns current snapshot; replace local state.
      const snapshot = await resp.json();
      this.reconcileFromSnapshot(snapshot);
      // IMPORTANT: drop whole queue since server state won
      this.saveQueue([]);
      return;
    }

    if (resp.status === 302) {
      // Redirect – session probably expired – stop syncing and reload page
      // to trigger login
      window.location.reload();
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
      // console.log(`synced timing state (turbo): ${this.playerId} - ${this.state} - ${this.timeValue}`);
      this.lastSyncAt = Date.now();
    } else {
      const snapshot = await resp.json();
      this.reconcileFromSnapshot(snapshot);
      // console.log(`synced timing state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
  
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
    // console.log(`reconciling from snapshot: ${this.playerId} - ${s.state} - ${s.total_seconds} - ${s.started_at} - v${s.version}`);
    this.setVersion(s.version);
    this.timeValue = s.total_seconds ?? this.timeValue;
    this.setItemDatasetCounter();
    this.state = s.state ?? this.state;
    this.startedAtMs = s.started_at ? Date.parse(s.started_at) : null;
    this.lastSyncAt = Date.now();
    // this.persistTimingState();
    this.render();
    this.setTimerOnState(); // start/stop local tickers to match state
  }

  handleOffline() {
    // console.log(`handling offline state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    switch (this.state) {
      case "start":
        this.state = "active";
        if (!this.startedAtMs)
          this.setStartedAtMs();
        this.enqueueStart();
        this.startTimer();
        this.renderNew();
        this.pausebuttonTarget.classList.remove("hidden");
        this.resumebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.remove("hidden");
        break;
      case "resume":
        this.state = "active";
        this.enqueueResume();
        if (!this.startedAtMs)
          this.setStartedAtMs();
        this.startTimer();
        this.setItemDatasetCounter();
        this.pausebuttonTarget.classList.remove("hidden");
        this.resumebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.remove("hidden");
        break;
      case "paused":
        this.enqueuePause();
        this.stopTimer();
        this.setItemDatasetCounter();
        this.pausebuttonTarget.classList.add("hidden");
        this.activelampTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        break;
      case "stopped":
        if (this.startedAtMs) {
          this.timeValue = this.getTimeValue();
          this.setItemDatasetCounter();
          this.startedAtMs = null;
        }
        this.enqueueStop();
        this.stopTimer();
        this.activelampTarget.classList.add("hidden");
        this.pausebuttonTarget.classList.add("hidden");
        this.resumebuttonTarget.classList.remove("hidden");
        break;
    }
    this.persistTimingState();
    this.checkInLater();
  }

  // Actions ------------------------------------------------------------------

  changeState(e){
    // console.log(`changing state: ${this.playerId} - ${this.state} - ${this.timeValue}`);
    this.state = e.target.dataset.state;

    if (navigator.onLine) {
      switch (this.state) {
        case "paused":
          this.stopTimer();
          break;
        case "stopped":
          this.stopTimer();
          break;
      }
      this.persistTimingState();
      // empty the queue first
      let ops = this.readQueue();
      if (ops.length > 0) {
        this.flushQueue()
        .then(() => { 
          const body = {
            ops: [{ type: this.state, at_ms: Date.now() }],
            version: this.getVersion()
          };
          const headers = {
            "X-CSRF-Token": this.token,
          };
          const url = this.changeStateUrlValue;
          this.flushQueue(body, url);
        });
      } else {
        const body = {
          ops: [{ type: this.state, at_ms: Date.now() }],
          version: this.getVersion(),
        };
        const headers = {
          "X-CSRF-Token": this.token,
        };
        const url = this.changeStateUrlValue;
        this.flushQueue(body, url);
      }
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

  rateChange(e) {
    console.log(`Rate change detected: ${e.currentTarget.value}`);
    // if (e.currentTarget.value != this.hourRate) {
    //   this.hourRate = e.currentTarget.value;
    // }
  }

  userChanged(e) {
    let tmr = document.getElementById("time_material_rate");

    const select = e.target;
    const selectedOption = select.options[select.selectedIndex];
    const hourlyRate = selectedOption.dataset.effective_hourly_rate;
    const validRate = parseFloat(hourlyRate);
    
    if (!isNaN(validRate)) {
      let val = this.empty_value(tmr, validRate);
      tmr.value = val;
    } else {
      console.warn(`Invalid userHourlyRate: ${hourlyRate}`);
      tmr.value = this.hourRate || 0.0;
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
          this.initialCustomer = document.querySelector( "#time_material_customer_id" ).value;
          let tmr = document.getElementById("time_material_rate");

          // // Add validation here too
          const dataRate = document.querySelector("#time_material_customer_id").dataset.lookupCustomerHourlyRate;
          const validRate = parseFloat(dataRate);

          if (!isNaN(validRate)) {
            let val = this.empty_value(tmr, validRate);
            tmr.value = val;
          } else {
            console.warn(`Invalid lookupCustomerHourlyRate: ${dataRate}`);
            tmr.value = this.hourRate || 0.0;
          }
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
          this.initialProject = document.querySelector( "#time_material_project_id" ).value;
          let tmr = document.getElementById("time_material_rate");

          // // Add validation here too
          const dataRate = document.querySelector("#time_material_project_id").dataset.lookupProjectHourlyRate;
          const validRate = parseFloat(dataRate);

          if (!isNaN(validRate)) {
            let val = this.empty_value(tmr, validRate);
            tmr.value = val;
          } else {
              console.warn(`Invalid lookupProjectHourlyRate: ${dataRate}`);
              tmr.value = this.hourRate || 0.0;
          }
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
    console.log(`hourRate: ${this.hourRate} - value: ${value}`);

    // Parse and validate the incoming value
    const parsedValue = parseFloat(value);
    const validValue = isNaN(parsedValue) ? 0.0 : parsedValue;

    if (validValue !== 0.0) {
      this.hourRate = validValue;
      console.log(`hourRate updated: ${this.hourRate}`);
      return validValue;
    }

    // Parse and validate the existing element value
    const existingValue = parseFloat(e.value);
    this.hourRate = isNaN(existingValue) ? 0.0 : existingValue;
    console.log(`use current hourRate: ${this.hourRate}`);
    return this.hourRate;
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

  renderNew(){
    // draw entire TimeMaterial Item when offline
  }
}
