import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = [ 
    "menuOpen", 
    "mobileMenu", 
    "menuClose"
  ]

  connect() {
    // console.log("Hello, Stimulus!", this.menuOpenTarget, this.menuCloseTarget)
  }

  toggleMenu() {
    this.menuOpenTarget.classList.toggle("hidden")
    this.menuCloseTarget.classList.toggle("hidden")
    this.mobileMenuTarget.classList.toggle("hidden")
    // this.menuOpenTarget, 
    // this.menuCloseTarget;
    // this.element.classList.toggle("hidden")
  }
}
