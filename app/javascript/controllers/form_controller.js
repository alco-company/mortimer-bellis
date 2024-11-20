import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form",
    "cancelForm"
  ]

  connect() {
    //
    // looking for a way to handle the redirect after a form submission
    //
    // first clear the event listener
    // this.element.removeEventListener("turbo:submit-end", this.next);
    // then add it again
    // this.element.addEventListener("turbo:submit-end", this.next);
    console.log("Connected to form controller")
  }

  keydown(e) {
    // e.preventDefault();
    switch(e.key) {
      case "Escape":
        this.cancelFormTarget.click()
        break;
      case "Enter":
        this.submitForm(e);
        break;
      // case "e":
      //   this.editForm(e);
      //   break;
      // case "c":
      //   this.clearForm(e);
      //   break;
      // case "q":
      //   this.closeForm(e);
      //   break;
      default:
        console.log(`[form_controller] you pressed ${e.key}`);
    }
  }

  // cancelForm(e) {
  //   e.preventDefault();
  //   let el = e.target;
  //   while('BUTTON' !== el.nodeName) {
  //     el = el.parentElement;
  //   }
  //   document.getElementById('form').innerHTML = ""
  // }

  editForm(e) {
    e.preventDefault();
    Turbo.visit(e.target.dataset.url);
  }

  submitForm(e) {
    e.preventDefault();
    Turbo.navigator.submitForm(this.formTarget);
    // this.formTarget.requestSubmit();
  }

  clearForm(e) {
    document.forms[0].reset();
    // this.formTarget.reset();
  }

  closeForm(e) {
   document.getElementById("form").innerHTML="";
  }

}
