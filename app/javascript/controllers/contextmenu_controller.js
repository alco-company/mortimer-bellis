import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js";
import { enter, leave } from "el-transition";

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
    event.stopPropagation();
    event.preventDefault();

    if (this.buttonTarget.getAttribute('aria-expanded') == "false") {
        this.show();
    } else {
        this.hide(event);
    }
  }

  show() {
    this.buttonTarget.setAttribute('aria-expanded', 'true');
    this.buttonTarget.classList.add('active');
    let list_items = document.querySelectorAll(".list_context_menu")
    if (this.lastItemInList(this.buttonTarget.closest(".list_item")) && list_items.length > 3) {
      this.popupTarget.classList.remove("top-0");
      this.popupTarget.classList.add("bottom-6");
    }
    enter(this.popupTarget);
    // this.popupTarget.classList.remove('hidden');
  }

  hide(event) {
    // event.stopPropagation();
    try {      
      if (
        event &&
        (this.popupTarget.contains(event.target) )
      ) {
        // changed your solution with crispinheneise's recommendation and added additional check:
        // event.preventDefault();
        if( event.target.tagName != 'A' && event.target.tagName != 'BUTTON' ) {
          return;
        }
      }

      this.buttonTarget.setAttribute("aria-expanded", "false");
      this.buttonTarget.classList.remove("active");
      // this.popupTarget.classList.add("hidden");
      leave(this.popupTarget);
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }  

  lastItemInList(item) {
    try {
      let records = document.getElementById("record_list").children
      return records[records.length - 1] == item
    } catch (error) {
      return false
    }
  }
}
