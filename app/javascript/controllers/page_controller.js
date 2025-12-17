import { Controller } from "@hotwired/stimulus"
// import PullToRefresh from "pulltorefreshjs";

// Connects to data-controller="page"
export default class extends Controller {
  connect() {

    const standalone = window.matchMedia("(display-mode: standalone)").matches;

    // if (standalone) {
    //   PullToRefresh.init({
    //     onRefresh() {
    //       window.location.reload();
    //     },
    //   });
    // }    
    // Ensure we have a fixed height container for scrolling
    const listContainer = document.getElementById("record_list");
    if (listContainer) {
      listContainer.style.maxHeight = "calc(100vh - 170px)"; // Adjust 200px based on your header/footer height
      listContainer.style.height = "calc(100vh - 170px)"; // 
      listContainer.style.overflowY = "auto";
    }
  }

  keydown(e) {
    if (e.metaKey){
      switch (e.key) {
        case "c":
          if (e.shiftKey)
            this.newCall(e);
          break;
        case "e":
          let form = document.getElementById("form");
          if (form.children.length > 0) {
            form
              .querySelectorAll("div")[9]
              .querySelectorAll("a")[0]
              .click();
          } else {
            this.editCurrentListItem();
          }
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
        case "+":
          document.getElementById("new_list_item").click();
          break;
        case "o":
          document.getElementById("new_task_item").click();
          break;
        case ",":
          this.editCurrentListItem();
          break;
        case "Delete":
          this.deleteCurrentListItem();
          break;
        case "ArrowUp":
          this.findPreviousListItem();
          break;
        case "ArrowDown":
          this.findNextListItem();
          break;
        case "Enter":
          this.showCurrentListItem();
          break;
        case "Escape":
          let form = document.getElementById("form");
          form = form.querySelectorAll("div")[8].querySelectorAll("a");
          if (form.length > 0) {
            form[0].click();
          }
          break;
        default:
          console.log(`[page_controller] you pressed ${e.key}`);
      }
    }
  }

  newCall() {
    let url = "/calls/new";
    fetch(url)
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  // find the edit_url like this
  // 
  showCurrentListItem() {
    let current = document.getElementsByClassName("current_list_item")[0] || document.getElementById("record_list").children[0]
    if (current) {
      current.classList.contains("current_list_item") ? current : current.classList.add("current_list_item")
      current = current
        .querySelectorAll("div")[2]
        .querySelectorAll("a")[0]
      if (current) current.click();
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

  deleteCurrentListItem() {
    let current = document.getElementsByClassName("current_list_item")[0] || document.getElementById("record_list").children[0]
    if (current) {
      current.classList.contains("current_list_item") ? current : current.classList.add("current_list_item")
      current = current
        .querySelectorAll("div")[6]
        .querySelectorAll("a[href*='delete'")[0]
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
