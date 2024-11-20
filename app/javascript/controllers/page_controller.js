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
}
