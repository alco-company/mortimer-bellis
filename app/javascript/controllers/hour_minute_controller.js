import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hour-minute"
export default class extends Controller {
  connect() {
    this.element.addEventListener("input", this.update.bind(this))
    this.element.addEventListener("keydown", this.disallowNonNumericInput);
    this.element.addEventListener("keyup", this.formatToHourMinute);
  }

  update(element) {
    console.log(`Updated: ${element.target.value}`)
  }

  disallowNonNumericInput(event) {
    if (event.key === 'Backspace' || event.key === 'Delete') {
      event.target.value = ''
      return;
    }
    if (event.key.length === 1 && isNaN(event.key)) {
      event.preventDefault();
    }
  }

  formatToHourMinute(event) {
    const input = event.target;
    const value = input.value.replace(/[^0-9]/g, '');
    const hour = value.substring(0, 2);
    const minute = value.substring(2, 4);
    input.value = `${hour}:${minute}`;
  }



}
