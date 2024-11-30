import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form",
    "cancelForm"
  ]

  connect() {
    document.getElementById("body").classList.add("overflow-y-hidden");
  }

  disconnect() {
    document.getElementById("body").classList.remove("overflow-y-hidden");
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
