import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-form"
export default class extends Controller {

  static targets = [
    "eventForm",
    "workButton",
    "freeButton",
    "sickButton",
    "workSpan",
    "freeSpan",
    "sickSpan",
    "workReason",
    "fromDate",
    "fromTime",
    "toDate",
    "toTime",
    "workOptions",
    "sickOptions",
    "freeOptions",
    "breakIncludedButton",
    "breakIncludedSpan",
    "breakIncludedInput",
    "durationInput",
    "autoPunch",
    "autoPunchSpan",
    "autoPunchButton",
    "allDay",
    "allDaySpan",
    "allDayButton",

    "notesTab",
    "notesButton",
    "recurringTab",
    "recurringButton",
  ];

  connect() {
    console.log("event ding 38");
  }

  // selectEventType(event) {
  //   const et = document.getElementsByClassName("event-type");
  //   for (let i = 0; i < et.length; i++) {
  //     if (et[i].classList.contains(event.target.value))
  //       et[i].classList.remove("hidden")
  //     else
  //       et[i].classList.add("hidden");
  //   }
  // }

  toggleWork(e) {
    this.setButton(e.target)
    this.setSwitch(this.workSpanTargets)
    this.workReasonTargets.forEach( (e) => { e.value = "in" })
    this.fromTimeTargets.forEach( (e) => { e.classList.remove("hidden") });
    this.toTimeTargets.forEach( (e) => { e.classList.remove("hidden") });
    this.durationInputTargets.forEach((e) => { e.classList.remove("hidden", "sm:hidden"); });
    this.sickOptionsTargets.forEach( (e) => { e.classList.add("hidden") });
    this.freeOptionsTargets.forEach( (e) => { e.classList.add("hidden") });
    this.workOptionsTargets.forEach( (e) => { e.classList.remove("hidden") });
  }

  toggleFree(e) {
    this.setButton(e.target);
    this.setSwitch(this.freeSpanTargets);
    this.workReasonTargets.forEach((e) => { e.value = "free"; });
    this.fromTimeTargets.forEach( (e) => { e.classList.remove("hidden") });
    this.toTimeTargets.forEach( (e) => { e.classList.remove("hidden") });
    this.durationInputTargets.forEach((e) => { e.classList.remove("hidden", "sm:hidden"); });
    this.sickOptionsTargets.forEach( (e) => { e.classList.add("hidden") })
    this.workOptionsTargets.forEach( (e) => { e.classList.add("hidden") });
    this.freeOptionsTargets.forEach( (e) => { e.classList.remove("hidden") });
  }

  toggleSick(e) {
    this.setButton(e.target);
    this.setSwitch(this.sickSpanTargets);
    this.workReasonTargets.forEach((e) => { e.value = "sick"; });
    this.fromTimeTargets.forEach( (e) => { e.classList.add("hidden")});
    this.toTimeTargets.forEach( (e) => { e.classList.add("hidden")});
    this.durationInputTargets.forEach( (e) => { e.classList.add("hidden", "sm:hidden") });
    this.sickOptionsTargets.forEach( (e) => { e.classList.remove("hidden")});
    this.freeOptionsTargets.forEach( (e) => { e.classList.add("hidden")});
    this.workOptionsTargets.forEach( (e) => { e.classList.add("hidden")});
  }

  toggleAllDay(e) {
    if (e.target.getAttribute("aria-checked") === "true") {
      this.allDayTargets.forEach( (e) => { e.value = "false" });
      e.target.setAttribute("aria-checked", "false");
      this.allDaySpanTargets.forEach( (e) => { e.classList.remove("translate-x-5")} );
    } else {
      this.allDayTargets.forEach( (e) => { e.value = "true"; });
      e.target.setAttribute("aria-checked", "true");
      this.allDaySpanTargets.forEach( (e) => { e.classList.add("translate-x-5")} );
    }
  }

  toggleAutoPunch(e) {
    if (e.target.getAttribute("aria-checked") === "true") {
      this.autoPunchTargets.forEach( (e) => { e.value = "false" });
      e.target.setAttribute("aria-checked", "false");
      this.autoPunchSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5")} );
    } else {
      this.autoPunchTargets.forEach( (e) => { e.value = "true"; });
      e.target.setAttribute("aria-checked", "true");
      this.autoPunchSpanTargets.forEach( (e) => { e.classList.add("translate-x-5")} );
    }
  }

  toggleBreakIncluded(e) {
    if (e.target.getAttribute("aria-checked") === "true") {
      this.breakIncludedInputTargets.forEach( (e) => { e.value = "false" });
      e.target.setAttribute("aria-checked", "false");
      this.breakIncludedSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5")} );
    } else {
      this.breakIncludedInputTargets.forEach( (e) => { e.value = "true"; });
      e.target.setAttribute("aria-checked", "true");
      this.breakIncludedSpanTargets.forEach( (e) => { e.classList.add("translate-x-5")} );
    }
  }

  // supporting functions

  setButton(e) {
    this.workButtonTargets.forEach( (e) => { e.setAttribute('aria-checked', 'false')});
    this.freeButtonTargets.forEach( (e) => { e.setAttribute('aria-checked', 'false')});
    this.sickButtonTargets.forEach( (e) => { e.setAttribute('aria-checked', 'false')});
    e.setAttribute('aria-checked', 'true');
  }
  setSwitch(el) {
    this.workSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5") });
    this.freeSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5") });
    this.sickSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5") });
    el.forEach( (e) => { e.classList.add("translate-x-5")})
  }
}
