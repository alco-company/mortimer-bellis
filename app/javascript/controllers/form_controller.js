import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form",
  ]

  connect() {
    // console.log("fisk");
  }

  clearForm(e) {
    document.forms[0].reset();
    // this.formTarget.reset();
  }

  closeForm(e) {
   document.getElementById("form").innerHTML="";
  }
}
