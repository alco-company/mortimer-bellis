import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = [
    "mobileSidebar",
    "sidebar",
    "menuitem",
    "topmain",
    "tsb",
    "setting"
  ];

  connect() {
    let i = 0;
    if (localStorage.getItem("collapsed") === "true") {
      this.topmainTarget.classList.remove("lg:pl-72");
      try { this.settingTargets.forEach((e) => e.classList.remove("px-6") ) } catch (e) {}
      this.topmainTarget.classList.add("lg:pl-32");
      this.sidebarTarget.classList.add("w-32", "max-w-32");
      this.menuitemTargets.forEach((e) => { e.classList.add("lg:hidden"); });
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.add("rotate-180");
      }
    }
  }

  toggleSidebar(e) {
    let i = 0;
    if (localStorage.getItem("collapsed") === "true") {
      this.topmainTarget.classList.remove("lg:pl-32");
      this.topmainTarget.classList.add("lg:pl-72");
      this.sidebarTarget.classList.remove("w-32", "max-w-32");
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.remove("rotate-180");
      }
      try {
        this.settingTargets.forEach((e) => e.classList.add("px-6"));
      } catch (e) {}
      this.menuitemTargets.forEach((e) => { e.classList.remove("lg:hidden"); });
      localStorage.setItem("collapsed", "false");
    } else {
      this.topmainTarget.classList.remove("lg:pl-72");
      this.topmainTarget.classList.add("lg:pl-32");
      this.sidebarTarget.classList.add("w-32", "max-w-32");
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.add("rotate-180");
      }
      try {
        this.settingTargets.forEach((e) => e.classList.remove("px-6"));
      } catch (e) {}
      this.menuitemTargets.forEach((e) => { e.classList.add("lg:hidden"); });
      localStorage.setItem("collapsed", "true");
    }
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
    let el = e.currentTarget
    el.setAttribute("aria-expanded", el.getAttribute("aria-expanded") === "true" ? "false" : "true");
    el.getElementsByTagName("svg")[0].classList.toggle("rotate-90");
    const submenu = el.parentElement.getElementsByClassName("submenu")[0];
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
