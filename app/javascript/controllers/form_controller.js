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
    // document.body.addEventListener( "touchmove", (e) => { e.preventDefault(); }, { passive: false } );
    document.documentElement.classList.add('lock-scroll'); // For html
    document.body.classList.add('lock-scroll'); // For body
    
    if (this.backdropTarget) enter(this.backdropTarget);
    enter(this.panelTarget);
  }

  disconnect() {
    document.getElementById("body").classList.remove("overflow-y-hidden");
    // document.body.removeEventListener( "touchmove", (e) => { e.preventDefault(); }, { passive: false } );
    document.documentElement.classList.remove("lock-scroll"); // For html
    document.body.classList.remove("lock-scroll"); // For body
  }

  keydown(e) {
    e.stopPropagation();
    if (e.metaKey){
      switch (e.key) {
        case "c":
          alert("new call");
          this.newCall(e);
          break;
        case "Enter":
          this.submitForm(e);
          break;
        // case "c":
        //   this.clearForm(e);
        //   break;
        // case "q":
        //   this.closeForm(e);
        //   break;
        // default:
        //   console.log(`[form_controller] you pressed ${e.key}`);
      }
    } else {
      switch (e.key) {
        case "Escape":
          leave(this.backdropTarget);
          leave(this.panelTarget).then(() => {
            this.cancelFormTarget.click();
          });
          break;
        case "Enter":
          this.submitForm(e);
          break;
      }
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

  newCall() {
    let url = "/calls/new";
    fetch(url)
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  editForm(e) {
    e.preventDefault();
    Turbo.visit(e.target.dataset.url);
  }

  submitForm(e) {
    e.preventDefault();
    leave(this.backdropTarget);
    leave(this.panelTarget)
    .then(() => {
      this.formTarget.requestSubmit();
      this.changeBrowserUrl();
      // Turbo.navigator.submitForm(this.formTarget);
    })
    .then(() => {
      this.closeForm(e);
      // this.formTarget.reset();
      // this.cancelButtonTarget.click();
    });
    // this.formTarget.requestSubmit();
  }

  clearForm(e) {
    document.forms[0].reset();
    // this.formTarget.reset();
  }

  closeForm(e) {
   document.getElementById("form").innerHTML="";
  }

  changeBrowserUrl() {
    const url = document.getElementById("cancel-form").href
    // const url = new URL(window.location.href.split("?")[0])
  
    // this.labelFilterValue.forEach((filter) => {
    //   url.searchParams.append("label[]", filter)
    // })
  
    history.pushState({}, null, url.toString())
    Turbo.navigator.history.replace(url.toString())
  }  

}
