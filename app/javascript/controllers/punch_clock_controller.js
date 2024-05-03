import { Application, Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// 1 Initialize
// 2 Input
// 3 Process Input
// 4 Output
// 5 Misc
export default class PunchClockController extends Controller {
  static targets = [
    "digitTap",
    "digitbox",
    "key",
    "keypad",
    "digit",
    "delete",
    "backspace",
    "search",
    "form",
    "modal",
    "message",
    "offlineWarning",
    "offlineWarningHeader",
  ];

  static values = {
    url: String, // where to do the lookup for data values
    apikey: String,
    punchClockAssetId: String,
    inLead: String,
    breakLead: String,
    outLead: String,
    badData: String,
  };

  //
  // 1 Initialize/Connect
  //
  // first we initialize the handset - on every connect
  connect() {
    this.digitCount = 0;
    this.digitKeys = [];
    this.addOfflineListener();
    // this.addWorkerListener();
  }

  disconnect() {
    super.disconnect();
  }

  // -- initialize dependant functions

  addOfflineListener() {
    window.addEventListener("offline", () => {
      this.offlineWarningTarget.classList.remove("hidden");
      this.offlineWarningHeaderTarget.classList.add("bg-red-500");
    });
    window.addEventListener("online", () => {
      window.location.reload();
    });
  }

  setReload() {
    if (this.scanset.length < 1) {
      window.location.reload();
    } else {
      this.shouldReload = true;
      this.reloadWarningTarget.classList.remove("hidden");
    }
  }

  addWorkerListener() {
    if (navigator.serviceWorker) {
      this.sendUrl();

      navigator.serviceWorker.addEventListener("message", (event) => {
        if (event.data === "reload!") {
          window.location.reload();
        }
        if (event.data === "url?") {
          this.sendUrl();
        }
      });
    }
  }

  sendUrl() {
    navigator.serviceWorker.ready.then((registration) => {
      let id = this.urlValue.split("/").slice(-1);
      let url =
      this.urlValue.split("/").slice(0, -1).join("/") + `/new?id=${id}`;
      registration.active.postMessage("url:" + url);
      console.log(`postPunch sent url: ${this.urlValue} `);
    });
  }

  //
  // 2 Input
  //
  // handle input - listen for keyboard - and functions for reacting to taps

  keydownHandler(e) {
    switch( e.key) {
      case "Backspace":
        e.preventDefault();
        this.backspaceTap(e);
        break;
      case "0":
      case "1":
      case "2":
      case "3":      
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        this.digitAdd(e.key);
        // this.keyTargets[this.digitCount].classList.add("bg-blue-200");
        // this.digitboxTargets[this.digitCount++].innerText = e.key;
        // this.digitKeys.push(e.key);
        break;
      case "Enter":
        e.preventDefault();
        this.handleBarcode(e.srcElement.value);
        break;
      case "Escape":
        e.preventDefault();
        break;
      default:
        break;
    }
  }

  // reveal the 4 digits filled by the user
  //
  digitboxTap(e) {
    for (const t of this.digitboxTargets) {
      if (t.classList.contains("hidden")) t.classList.remove("hidden");
      else t.classList.add("hidden");
    }
  }

  // respond to taps on the keypad
  digitTap(e) {
    this.digitAdd(e.srcElement.innerText);
    // if (this.digitCount < 4) {
    //   this.keyTargets[this.digitCount].classList.add("bg-blue-200");
    //   this.digitboxTargets[this.digitCount++].innerText =
    //     e.srcElement.innerText;
    //   this.digitKeys.push(e.srcElement.innerText);
    //   if (this.digitKeys.length == 4) {
    //     this.getEmployee();
    //   }
    // } else {
    //   alert("Du skal kun indtaste 4 cifre");
    // }
  }

  digitAdd(i) {
    if (this.digitCount < 4) {
      this.keyTargets[this.digitCount].classList.add("bg-blue-200");
      this.digitboxTargets[this.digitCount++].innerText = i;
      this.digitKeys.push(i);
      if (this.digitKeys.length == 4) {
        this.getEmployee();
      }
    } else {
      alert("Du skal kun indtaste 4 cifre");
    }
  }

  // get back to the keypad
  deleteTap(e) {
    for (const t of this.digitboxTargets) {
      t.innerText = "";
    }
    for (const t of this.keyTargets) {
      t.classList.remove("bg-blue-200");
    }
    this.digitCount = 0;
    window.location.href = `${this.urlValue}?api_key=${this.apikeyValue}`;
  }

  // clear last input digit
  backspaceTap(e) {
    if (this.digitCount > 0) {
      this.digitboxTargets[--this.digitCount].innerText = "";
      this.keyTargets[this.digitCount].classList.remove("bg-blue-200");
      this.digitKeys.pop();
    }
  }

  // punch the employee IN
  playTap(e) {
    if (e.currentTarget.classList.contains("disabled")) return;

    let data = {
      asset_work_transaction: {
        punched_at: new Date().toISOString(),
        state: "IN",
        employee_id: e.currentTarget.dataset.employeeId,
      },
    };

    this.openModal(this.inLeadValue, data);
  }

  // punch the employee for BREAK
  pauseTap(e) {
    if (e.currentTarget.classList.contains("disabled")) return;
    let data = {
      asset_work_transaction: {
        punched_at: new Date().toISOString(),
        state: "BREAK",
        employee_id: e.currentTarget.dataset.employeeId,
      },
    };

    this.openModal(this.breakLeadValue, data);
  }

  // punch the employee for OUT
  stopTap(e) {
    if (e.currentTarget.classList.contains("disabled")) return;
    let data = {
      asset_work_transaction: {
        punched_at: new Date().toISOString(),
        state: "OUT",
        employee_id: e.currentTarget.dataset.employeeId,
      },
    };

    this.openModal(this.outLeadValue, data);
  }

  // for now tapping the status row listing the queue in the background worker
  // will reload the web app
  emptyQueue(e) {
    window.location.reload();
  }

  // -- input dependant functions

  //
  // 3 Process Input
  //
  // process input - send good scans to the background worker

  // - process dependant function

  openModal(msg, data) {
    this.messageTarget.innerText = msg;
    this.modalTarget.classList.remove("hidden");
    this.postPunch(data);
    // setTimeout(
    //   () => {
    //     this.modalTarget.classList.add("hidden");
    //     this.postPunch(data);
    //   },
    //   2000,
    //   this,
    //   data
    // );
  }

  getEmployee(url = "") {
    this.searchTarget.value = this.digitKeys.join("");
    Turbo.navigator.submitForm(this.formTarget);
  }

  //
  // 4 Output
  //
  // handle output - send good scans to the background worker - and update the UI

  //
  // we queue the scans that are 'ready' - ie holds a SSCS, EAN14, and PRIV at least
  // sending them off to the queue Worker eventually
  //

  // - output dependant functions

  // ***** UI *****

  //
  // 5 Misc
  //
  // support functions like logging and more

  tellMap(map, from) {
    let type = map.get("type");
    const json = JSON.stringify(Object.fromEntries(map));
    console.log(`Show Map ${from}-${this.scanset.length}-----`);
    console.log(`map ${type} ${map.get(type)}: `);
    console.log(`${json}`);
    console.log("Show Map ------------------------------ done");
  }

  handleMessages(e) {
    // console.log(`an event ${e} with ${e.detail.message} was received in ${this.identifier}`)
  }

  // postPunch
  // transmits the punch
  // and possibly (if told so in the result) asks
  // the terminal to reload
  //
  // on error it unshifts the data back on the queue
  //

  // let urlMethod = "POST";
  // let urlUrl = "";
  // let csrfToken = null;
  // let urlHeaders = "";
  // let apiKey = "";

  // { "asset_work_transaction"=> {
  //   "punched_at"=>"2022-09-29 12:05:12",
  //   "state"=>"OUT",
  //   "employee_id"=>"#{ @emp_one.id }",
  //   "punch_asset_id"=>"#{ @punch_asset.id }",
  //   "ip_addr"=>"10.4.3.170"
  //   },
  //   "api_key"=>"[FILTERED]"
  // }

  // url = `${urlUrl}?api_key=${apiKey}`
  // post_data = {}
  // data.forEach( (v,k) => post_data[k]=v )
  // postPunch(url, urlMethod, urlHeaders, { asset_work_transaction: post_data }, data)

  postPunch(data, url = null) {

    try {
      const csrfToken = document.querySelector("[name='csrf-token']").content;
      let headers = {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json",
      };
      if (!url) url = `${this.urlValue}?api_key=${this.apikeyValue}`;
      else url = `${url}?api_key=${this.apikeyValue}`;

      let options = {
        method: "POST",
        // mode: 'no-cors',
        // cache: 'no-cache',
        // redirect: 'follow',
        // referrerPolicy: 'no-referrer',
        // credentials: 'same-origin',
        // responseKind: "json",
        headers: headers,
        body: JSON.stringify(data),
      };

      fetch(url, options)
        .then((response) => {
          switch (response.status) {
            case 200:
              window.location.reload();
              return true;
            case "200":
              window.location.reload();
              return true;
            case 201:
              window.location.reload();
              return true;
            case "201":
              window.location.reload();
              return true;
            case 301:
              this.messageTarget.innerText = this.badDataValue;
              console.log("bad api_key!");
              return false;
              case 302:
              this.messageTarget.innerText = this.badDataValue;
              console.log("bad STATE!");
              return false;
            default:
              return false;
          }
          return true;
        })
        .catch((err) => {
          console.log(`postPunch error: ${err}`);
        });
    } catch (err) {
      console.log(`postPunch response: ${err} `);
      return false;
    }
  }
}