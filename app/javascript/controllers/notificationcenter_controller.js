import { Controller } from "@hotwired/stimulus"
import { useTransition } from "stimulus-use";

// Connects to data-controller="notificationcenter"
export default class extends Controller {
  static targets = [ 
    "notificationCenter",
    "slideoverpanel",
    "notificationBell",
    "notificationBellButton"
  ]

  connect() {
    useTransition(this, {
      element: this.slideoverpanelTarget,
      enterActive: "transform transition ease-in-out duration-500 sm:duration-1000",
      enterFrom: "translate-x-full",
      enterTo: "translate-x-0",
      leaveActive: "transform transition ease-in-out duration-500 sm:duration-1000",
      leaveFrom: "translate-x-0",
      leaveTo: "translate-x-full",
      hiddenClass: "hidden",
    });
    this.leave()
  }

  toggle() {

    if (
      this.notificationBellButtonTarget.getAttribute("aria-expanded") == "false"
    ) {
      this.notificationBellButtonTarget.setAttribute("aria-expanded", "true");
      this.notificationCenterTarget.classList.remove("hidden");
      this.toggleTransition();
    } else {
      this.toggleTransition()
      this.timeout = setTimeout(() => {
        this.notificationCenterTarget.classList.add("hidden");      
      }, 1200);

      this.notificationBellButtonTarget.setAttribute("aria-expanded", "false");
    }
  }

  gong(event) {
    event.preventDefault();
    this.toggle()
  }

  bye(event) {
    try {      
      if (
        event &&
        (this.notificationBell.contains(event.target) ||
          this.notificationBellButtonTarget.contains(event.target))
      ) {
        // changed your solution with crispinheneise's recommendation and added additional check:
        // event.preventDefault();
        if (event.target.tagName != "A") return;
      }

      this.notificationBellButtonTarget.setAttribute("aria-expanded", "false");
      this.leave();
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }


}
