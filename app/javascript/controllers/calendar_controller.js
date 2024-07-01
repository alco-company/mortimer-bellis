import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "view_dropdown"
  ]

  connect() {
    console.log(this.view_dropdownTarget)
  }

  toggleView(event) {
    try {      
      event.preventDefault()
      event.stopPropagation()
      this.view_dropdownTarget.classList.toggle("hidden");
    } catch (error) {
      console.error("Error in toggle function: ", error);
    }
  }

  hideView(event) {
    // event.preventDefault()
    try {      
      // console.log(`hide ${event.target}`);
      // if (
      //   event &&
      //   (this.view_dropdownTarget.contains(event.target) || 
      //     this.view_dropdownTarget == event.target)) {
      //   // changed your solution with crispinheneise's recommendation and added additional check:
      //   // event.preventDefault();
      //   // if( event.target.tagName != 'A')
      //     return;
      // }

      this.view_dropdownTarget.classList.add("hidden");
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }
}
