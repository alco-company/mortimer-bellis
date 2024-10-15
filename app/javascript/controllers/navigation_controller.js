import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = [ 
    "menuOpen", 
    "mobileMenu", 
    "menuClose",
    "profileMenu",
    "profileMenuButton",
    "viewNotifications",
    "viewNotificationsButton",
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

  toggleProfileMenu() {
    console.log("profile")
    // this.profileMenuTarget.classList.toggle("hidden")
  }

  tapDrop(event) {
      // removed event.stopPropagation() to continue the bubbling for others dropdowns
    event.preventDefault();

    if (this.profileMenuButtonTarget.getAttribute("aria-expanded") == "false") {
      this.showDrop();
    } else {
      this.hideDrop(null);
    }
  }

  tapNotificationDrop(event) {
    event.preventDefault();

    if (this.viewNotificationsButtonTarget.getAttribute("aria-expanded") == "false") {
      this.showNotificationDrop();
    } else {
      this.hideNotificationDrop(null);
    }
  }

  showNotificationDrop() {
    this.viewNotificationsButtonTarget.setAttribute("aria-expanded", "true");
    this.viewNotificationsButtonTarget.classList.add("active");
    this.viewNotificationsTarget.classList.remove("hidden");
  }

  hideNotificationDrop(event) {
    try {      
      if (
        event &&
        (this.viewNotificationsTarget.contains(event.target) ||
          this.viewNotificationsButtonTarget.contains(event.target))
      ) {
        // changed your solution with crispinheneise's recommendation and added additional check:
        // event.preventDefault();
        if (event.target.tagName != "A") return;
      }

      this.viewNotificationsButtonTarget.setAttribute("aria-expanded", "false");
      this.viewNotificationsButtonTarget.classList.remove("active");
      this.viewNotificationsTarget.classList.add("hidden");
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }

  showDrop() {
    this.profileMenuButtonTarget.setAttribute('aria-expanded', 'true');
    this.profileMenuButtonTarget.classList.add('active');
    this.profileMenuTarget.classList.remove("hidden");
  }

  hideDrop(event) {
    try {      
      if (
        event &&
        (this.profileMenuTarget.contains(event.target) ||
          this.profileMenuButtonTarget.contains(event.target))
      ) {
        // changed your solution with crispinheneise's recommendation and added additional check:
        // event.preventDefault();
        if (event.target.tagName != "A") return;
      }

      this.profileMenuButtonTarget.setAttribute("aria-expanded", "false");
      this.profileMenuButtonTarget.classList.remove("active");
      this.profileMenuTarget.classList.add("hidden");
    } catch (error) {
      console.error("Error in hide function: ", error);
      return
    }
  }  


}
