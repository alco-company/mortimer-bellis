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
  }

  keydown(e) {
    switch(e.key) {
      case "+":       document.getElementById("new_list_item").click(); break;
      case "Escape":  break;
      default:        console.log(`[page_controller] you pressed ${e.key}`);
    }
  }
}
