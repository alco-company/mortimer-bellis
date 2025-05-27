import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-material-stats"
export default class extends Controller {
  connect() {
  }

  async changeRangeView(e) {

    const response = await fetch(`/time_material_stats?range_view=${e.currentTarget.value}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.token,
        "Content-Type": "text/vnd.turbo-stream.html",
      },
    });

    if (response.status === 204) {
      return true;
    } else {
      const text = await response.text();
      Turbo.renderStreamMessage(text);
    }
  }
}
