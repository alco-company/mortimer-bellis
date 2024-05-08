import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pos-employee"
export default class extends Controller {
  static targets = [ 
    "manualForm",
    "workButton",
    "freeButton",
    "sickButton",
    "workSpan",
    "freeSpan",
    "sickSpan",
    "fromAt",
    "toAt",
    "workReason",
    "sickOptions",
    "freeOptions"
  ]

  connect() {
    console.log("ding");
  }

  clearForm() {
    this.manualFormTarget.remove();
  }

  toggleWork(e) {
    this.setButton(e.target)
    this.setSwitch(this.workSpanTarget)
    this.workReasonTarget.setAttribute("checked", "checked")
    this.fromAtTarget.setAttribute("type", "datetime-local");
    this.toAtTarget.setAttribute("type", "datetime-local");
    this.sickOptionsTarget.classList.add("hidden")
    this.freeOptionsTarget.classList.add("hidden")
  }

  toggleFree(e) {
    this.setButton(e.target);
    this.setSwitch(this.freeSpanTarget);
    this.fromAtTarget.setAttribute("type", "datetime-local");
    this.toAtTarget.setAttribute("type", "datetime-local");
    this.sickOptionsTarget.classList.add("hidden")
    this.freeOptionsTarget.classList.remove("hidden")
  }

  toggleSick(e) {
    this.setButton(e.target);
    this.setSwitch(this.sickSpanTarget);
    this.fromAtTarget.setAttribute("type", "date");
    this.toAtTarget.setAttribute("type", "date");
    this.sickOptionsTarget.classList.remove("hidden")
    this.freeOptionsTarget.classList.add("hidden")
  }

  setButton(e) {
    this.workButtonTarget.setAttribute('aria-checked', 'false');
    this.freeButtonTarget.setAttribute('aria-checked', 'false');
    this.sickButtonTarget.setAttribute('aria-checked', 'false');
    e.setAttribute('aria-checked', 'true');
  }
  setSwitch(e) {
    this.workSpanTarget.classList.remove("translate-x-5");
    this.freeSpanTarget.classList.remove("translate-x-5");
    this.sickSpanTarget.classList.remove("translate-x-5");
    e.classList.add("translate-x-5")
  }
}
