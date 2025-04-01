import { Controller } from "@hotwired/stimulus"
import PullToRefresh from "pulltorefreshjs";

// Connects to data-controller="page"
export default class extends Controller {
  connect() {

    const standalone = window.matchMedia("(display-mode: standalone)").matches;

    if (standalone) {
      PullToRefresh.init({
        onRefresh() {
          window.location.reload();
        },
      });
    }    
    // Ensure we have a fixed height container for scrolling
    const listContainer = document.getElementById("record_list");
    if (listContainer) {
      listContainer.style.maxHeight = "calc(100vh - 180px)"; // Adjust 200px based on your header/footer height
      listContainer.style.height = "calc(100vh - 180px)"; // 
      listContainer.style.overflowY = "auto";
    }
  }

  keydown(e) {
    switch(e.key) {
      case "+":         document.getElementById("new_list_item").click(); break;
      case ",":         this.editCurrentListItem(); break;
      case "ArrowUp": this.findPreviousListItem(); break;
      case "ArrowDown": this.findNextListItem(); break;
      case "Escape":    break;
      default:        console.log(`[page_controller] you pressed ${e.key}`);
    }
  }

  // find the edit_url like this
  // 
  editCurrentListItem() {
    let current = document.getElementsByClassName("current_list_item")[0] || document.getElementById("record_list").children[0]
    if (current) {
      current.classList.contains("current_list_item") ? current : current.classList.add("current_list_item")
      current = current
        .querySelectorAll("div")[6]
        .querySelectorAll("a[href$='edit'")[0]
      if (current) current.click();
    }
  }

  findNextListItem() {
    let listContainer = document.getElementById("record_list");
    let current = document.querySelector(".current_list_item");
    
    if (!current && listContainer.children.length > 0) {
      current = listContainer.children[0];
    }

    if (current) {
      let next = current.nextElementSibling;
      
      if (next) {
        current.classList.remove("current_list_item");
        next.classList.add("current_list_item");
        const offset = next.offsetTop - (listContainer.clientHeight / 2) + (next.clientHeight / 2);
        listContainer.scrollTo({
          top: offset,
          behavior: 'smooth'
        });
      }
    }
  }
  findPreviousListItem() {
    let listContainer = document.getElementById("record_list");
    let current = document.querySelector(".current_list_item");
    
    if (!current && listContainer.children.length > 0) {
      current = listContainer.children[0];
    }

    if (current) {
      let previous = current.previousElementSibling;
      
      if (previous) {
        current.classList.remove("current_list_item");
        previous.classList.add("current_list_item");
        const offset = previous.offsetTop - (listContainer.clientHeight / 2) + (previous.clientHeight / 2);
        listContainer.scrollTo({
          top: offset,
          behavior: 'smooth'
        });
      }
    }
  }
}
