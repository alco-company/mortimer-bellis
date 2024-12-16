import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [
    "form",
    "cancelForm",
    "backdrop", 
    "panel", 
    "cancelButton"
  ]

  connect() {
    document.getElementById("body").classList.add("overflow-y-hidden");
    document.body.addEventListener( "touchmove", (e) => { e.preventDefault(); }, { passive: false } );
    document.documentElement.classList.add('lock-scroll'); // For html
    document.body.classList.add('lock-scroll'); // For body
    
    enter(this.backdropTarget);
    enter(this.panelTarget);
  }

  disconnect() {
    document.getElementById("body").classList.remove("overflow-y-hidden");
    document.body.removeEventListener( "touchmove", (e) => { e.preventDefault(); }, { passive: false } );
    document.documentElement.classList.remove("lock-scroll"); // For html
    document.body.classList.remove("lock-scroll"); // For body
  }

  keydown(e) {
    // e.preventDefault();
    switch(e.key) {
      case "Escape":
        leave(this.backdropTarget);
        leave(this.panelTarget).then(() => {
          this.cancelFormTarget.click()
        });
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
    leave(this.backdropTarget);
    leave(this.panelTarget).then(() => {
      Turbo.navigator.submitForm(this.formTarget);
    })
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
