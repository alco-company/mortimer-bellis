import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form",
  ]

  connect() {
    console.log("fisk");
    console.log(this.formTarget);
  }

  cancelForm(e) {
    e.preventDefault();
    let el = e.target;
    while('BUTTON' !== el.nodeName) {
      el = el.parentElement;
    }
    document.getElementById('form').innerHTML = ""
  }

  submitForm(e) {
    e.preventDefault();
    this.formTarget.requestSubmit();
  }

  clearForm(e) {
    document.forms[0].reset();
    // this.formTarget.reset();
  }

  closeForm(e) {
   document.getElementById("form").innerHTML="";
  }
}
