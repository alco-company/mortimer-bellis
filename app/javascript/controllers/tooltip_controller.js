import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tooltip"
export default class extends Controller {
  connect() {
  }

  placeTooltip(event) {
    const tooltip = document.querySelector("turbo-frame#tooltip");
    console.log(`${event.clientX}px`, `${event.clientY}px`)
    tooltip.style.left = `${event.clientX-50}px`;
    tooltip.style.top = `${event.clientY-10}px`;
    tooltip.classList.remove("hidden");

    tooltip.addEventListener("mouseleave", () => {
      tooltip.classList.add("hidden");
    });
  }
}
