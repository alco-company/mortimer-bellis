import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = [
    "mobileSidebar",
  ];

  connect() {
    console.log("Connected to menu controller")
  }

  toggleFlyout(e) {
    // e.preventDefault()
    const flyout = e.target.getElementsByClassName("flyout")[0];
    const collection = document.getElementsByClassName("flyout");
    for (let i = 0; i < collection.length; i++) {
      if (collection[i] !== flyout)
        collection[i].classList.add("hidden");
    }
    e.target.getElementsByClassName("flyout")[0].classList.toggle("hidden");
  }

  toggleSubmenu(e) {
    e.preventDefault()
    e.target.setAttribute("aria-expanded", e.target.getAttribute("aria-expanded") === "true" ? "false" : "true");
    e.target.getElementsByTagName("svg")[0].classList.toggle("rotate-90");
    const submenu = e.target.parentElement.getElementsByClassName("submenu")[0];
    const collection = document.getElementsByClassName("submenu");
    for (let i = 0; i < collection.length; i++) {
      if (collection[i] !== submenu)
        collection[i].classList.add("hidden");
    }
    submenu.classList.toggle("hidden");
  }

  openMobileSidebar(e) {
    console.log("openMobileSidebar")
    this.mobileSidebarTarget.classList.remove("hidden");
  }

  closeMobileSidebar(e) {
    this.mobileSidebarTarget.classList.add("hidden");
  }
}
