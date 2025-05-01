import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition";

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = [
    "mobileSidebar",
    "sidebar",
    "menuitem",
    "topmain",
    "tsb",
    "setting",
    "progress"
  ];

  connect() {
    let i = 0;
    if (localStorage.getItem("collapsed") === "true") {
      this.topmainTarget.classList.remove("lg:pl-64");
      this.topmainTarget.classList.add("lg:pl-24");
      this.settingTarget.classList.remove("w-64"); 
      this.settingTarget.classList.add("w-24");
      this.settingTarget.classList.add("max-w-24");
      this.sidebarTarget.classList.add("w-24", "max-w-24");
      this.progressTarget.classList.add("hidden");
      this.menuitemTargets.forEach((e) => { e.classList.add("lg:hidden"); });
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.add("rotate-180");
      }
    } else {
      this.settingTarget.classList.remove("w-24", "max-w-24");
      this.settingTarget.classList.add("w-64");
    }
  }

  toggleSidebar(e) {
    let i = 0;
    // going wide
    if (localStorage.getItem("collapsed") === "true") {
      this.settingTarget.classList.remove("w-24", "max-w-24");
      this.settingTarget.classList.add("w-64");
      this.topmainTarget.classList.remove("lg:pl-24");
      this.topmainTarget.classList.add("lg:pl-64");
      this.sidebarTarget.classList.remove("w-24", "max-w-24");
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.remove("rotate-180");
      }
      this.menuitemTargets.forEach((e) => { e.classList.remove("lg:hidden"); });
      this.progressTarget.classList.remove("hidden");
      localStorage.setItem("collapsed", "false");

    // going narrow
    } else {
      this.topmainTarget.classList.remove("lg:pl-64");
      this.topmainTarget.classList.add("lg:pl-24");
      this.sidebarTarget.classList.add("w-24", "max-w-24");
      for (i of document.getElementsByClassName("collapse-sidebar")) {
        i.classList.add("rotate-180");
      }
      this.settingTarget.classList.remove("w-64");
      this.settingTarget.classList.add("w-24");
      this.settingTarget.classList.add("max-w-24");
      this.menuitemTargets.forEach((e) => { e.classList.add("lg:hidden"); });
      this.progressTarget.classList.add("hidden");
      localStorage.setItem("collapsed", "true");
    }
  }

  // toggleFlyout(e) {
  //   // e.preventDefault()
  //   const flyout = e.target.getElementsByClassName("flyout")[0];
  //   const collection = document.getElementsByClassName("flyout");
  //   for (let i = 0; i < collection.length; i++) {
  //     if (collection[i] !== flyout)
  //       collection[i].classList.add("hidden");
  //   }
  //   e.target.getElementsByClassName("flyout")[0].classList.toggle("hidden");
  // }

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
      this.settingTarget.classList.remove("w-64");
      this.settingTarget.classList.add("w-24");
      this.settingTarget.classList.add("max-w-24");

  }

  // openMobileSidebar(e) {
  //   this.toggleTransition();
  //   // this.mobileSidebarTarget.classList.remove("hidden");
  // }

  // closeMobileSidebar(e) {
  //   this.mobileSidebarTarget.classList.add("hidden");
  // }
}
