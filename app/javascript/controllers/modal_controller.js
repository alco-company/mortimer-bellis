import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop", "dialog", "dismiss"];

  connect() {
    // this.element.dataset.action = "modal#show";
    // console.log("Modal controller connected");
    // this.backdropEnteringClass =
    //   this.backdropTarget.dataset.enteringClasses || "";
    // this.backdropLeavingClass = this.backdropTarget.dataset.leavingClasses || "";

    // this.dialogEnteringClass = this.dialogTarget.dataset.enteringClasses || "";
    // this.dialogLeavingClass = this.dialogTarget.dataset.leavingClasses || "";

    // // Use an animation frame to remove the backdrop leaving classes that might be there
    // // and add the backdrop entering classes.
    // requestAnimationFrame(() => {
    //   this.backdropTarget.classList.remove(
    //     ...this.backdropLeavingClass.split(" ")
    //   );
    //   this.backdropTarget.classList.add(
    //     ...this.backdropEnteringClass.split(" ")
    //   );
    // });

    // // Use an animation frame to remove any dialog leaving classes that might be there
    // // and add the dialog entering classes.
    // requestAnimationFrame(() => {
    //   this.dialogTarget.classList.remove(...this.dialogLeavingClass.split(" "));
    //   this.dialogTarget.classList.add(...this.dialogEnteringClass.split(" "));
    // });
    document.body.addEventListener("touchmove", (e)=>{ e.preventDefault() }, { passive: false, });
    document.documentElement.classList.add('lock-scroll'); // For html
    document.body.classList.add('lock-scroll'); // For body
  }

  disconnect() {
    // this.backdropTarget.classList.remove(
    //   ...this.backdropEnteringClass.split(" ")
    // );
    // this.backdropTarget.classList.remove(...this.backdropLeavingClass.split(" "));

    // this.dialogTarget.classList.remove(...this.dialogEnteringClass.split(" "));
    // this.dialogTarget.classList.remove(...this.dialogLeavingClass.split(" "));
    document.body.removeEventListener( "touchmove", (e) => { e.preventDefault(); }, { passive: false } );
    document.documentElement.classList.remove('lock-scroll'); // For html
    document.body.classList.remove('lock-scroll'); // For body
  }

  show(event) {
    const dialog = document.getElementById(event.params.dialog);
    dialog.showModal();
  }  

  closeDialog(event) {
    const dialog = document.getElementById(event.target.data.dialog);
    console.log(dialog);
    dialog.close();
  }

  close(e) {
    // e.preventDefault();
    // const abortListener = new AbortController();

    // requestAnimationFrame(() => {
    //   this.backdropTarget.classList.remove(
    //     ...this.backdropEnteringClass.split(" ")
    //   );
    //   this.backdropTarget.classList.add(...this.backdropLeavingClass.split(" "));
    // });

    // this.dialogTarget.addEventListener(
    //   "transitionend",
    //   () => {
    //     // Remove this event listener because otherwise multiple transitions will
    //     // cause this function to be called N times, and will generate a console
    //     // error about the user aborting a request due to the modelEl.src being
    //     // set multiple times. Listening for one `transitionend` is fine, because
    //     // they all have a single duration anyway.
    //     abortListener.abort();

    //     // Manually we take the close link's href and set the modal turbo frame's
    //     // src to that path (in this case the /close_modal path), which will clear
    //     // the modal from the screen, magically, thanks to Turbo Frames.
    //     const href = this.dismissTarget.dataset.url;
    //     const modalEl = document.querySelector("#new_form_modal");
    //     console.log(modalEl)
    //     modalEl.src = href;
    //   },
    //   { signal: abortListener.signal }
    // );

    // requestAnimationFrame(() => {
    //   this.dialogTarget.classList.remove(...this.dialogEnteringClass.split(" "));
    //   this.dialogTarget.classList.add(...this.dialogLeavingClass.split(" "));
    // });

  }

}
