import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-material-stats"
export default class extends Controller {
  connect() {
  }

  changeRangeView(e) {
    fetch(`/time_material_stats?range_view=${e.currentTarget.value}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "text/vnd.turbo.stream.html",
      },
    });
  }
}
