import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition";

// Connects to data-controller="notificationcenter"
export default class extends Controller {
  static targets = [ 
    "notificationCenter",
    "backdrop",
    "slideoverpanel",
    "notificationBell",
    "notificationBellButton"
  ]

  connect() {
    this.backdropTarget.classList.add("bg-black", "bg-opacity-50");
    this.backdropTarget.classList.remove("hidden");
    console.log(this.backdropTarget);
  }


  show() {
    this.notificationCenterTarget.classList.remove("hidden");
    enter(this.backdropTarget);
    enter(this.slideoverpanelTarget);
  }

  hide() {
    Promise.all([
      leave(this.backdropTarget),
      leave(this.slideoverpanelTarget),
    ]).then(() => {
      this.notificationCenterTarget.classList.add("hidden");
    });
  }


  toggle() {

    if (
      this.notificationBellButtonTarget.getAttribute("aria-expanded") == "false"
    ) {
      this.notificationBellButtonTarget.setAttribute("aria-expanded", "true");
      this.show()
    } else {
      this.hide()

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

      // this.notificationBellButtonTarget.setAttribute("aria-expanded", "false");
      this.hide();
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }


}
