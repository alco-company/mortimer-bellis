import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-button"
export default class extends Controller {

  static targets = [
    "toggle",
    "toggleSpan",
    "toggleButton",
    "templateSpan",
    "newTemplate"
  ];

  connect() {
    console.log("toggle ding");
  }

  toggle(e) {
    if (e.target.getAttribute("aria-checked") === "true") {
      this.toggleTargets.forEach( (e) => { e.value = 0; e.classList.remove("bg-sky-200"); e.classList.add("bg-gray-200");});
      e.target.setAttribute("aria-checked", "false");
      this.toggleSpanTargets.forEach( (e) => { e.classList.remove("translate-x-5")} );
      this.templateSpanTargets.forEach( (e) => { e.classList.add("hidden")} );
      this.newTemplateTargets.forEach((e) => { e.classList.add("hidden"); });
    } else {
      this.toggleTargets.forEach( (e) => { e.value = 1; e.classList.add("bg-sky-200"); e.classList.remove("bg-gray-200");});
      e.target.setAttribute("aria-checked", "true");
      this.toggleSpanTargets.forEach( (e) => { e.classList.add("translate-x-5")} );
      this.templateSpanTargets.forEach( (e) => { e.classList.remove("hidden")} );
      this.newTemplateTargets.forEach((e) => { e.classList.remove("hidden"); });
    }
  }
}
