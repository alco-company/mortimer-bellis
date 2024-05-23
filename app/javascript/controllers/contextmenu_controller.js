import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js";

// Connects to data-controller="contextmenu"
export default class extends Controller {
  static targets = [ "button", "popup" ]
  connect() {
  }

  unfold(event) {
    event.preventDefault();
    if (this.buttonTarget.getAttribute('aria-expanded')=='false') {
      get(this.buttonTarget.getAttribute("href"));
    }
  }

  tap(event) {
      // removed event.stopPropagation() to continue the bubbling for others dropdowns
    event.preventDefault();

    if (this.buttonTarget.getAttribute('aria-expanded') == "false") {
        this.show();
    } else {
        this.hide(null);
    }
  }

  show() {
    this.buttonTarget.setAttribute('aria-expanded', 'true');
    this.buttonTarget.classList.add('active');
    this.popupTarget.classList.remove('hidden');
  }

  hide(event) {
    try {      
      if (
        event &&
        (this.popupTarget.contains(event.target) ||
          this.buttonTarget.contains(event.target))
      ) {
        // changed your solution with crispinheneise's recommendation and added additional check:
        // event.preventDefault();
        if( event.target.tagName != 'A')
          return;
      }

      this.buttonTarget.setAttribute("aria-expanded", "false");
      this.buttonTarget.classList.remove("active");
      this.popupTarget.classList.add("hidden");
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }  
}
