import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pomodoro"
export default class extends Controller {
  static targets = [ 
    "pomodorotimer"
  ]

  connect() {
    navigator.serviceWorker.controller.postMessage({ type: "INIT_POMODORO_TIMER" });
    navigator.serviceWorker.addEventListener("message",  (event) => {
      // Print the result
      console.log(`event ${event.data.type} ${event.data.payload}`);
      if (event.data.type === "PLAY") {
        this.play();
        this.pomodorotimerTarget.innerText = event.data.payload;
      } else {
        this.pomodorotimerTarget.innerText = event.data.payload;
      }
    });    
  }

  start(e) {
    e.stopPropagation();
    navigator.serviceWorker.controller.postMessage({ type: "START_POMODORO_TIMER" });
  }

  pause(e) {
    e.stopPropagation();
    navigator.serviceWorker.controller.postMessage({
      type: "STOP_POMODORO_TIMER",
    });
  }

  restart(e) {
    e.stopPropagation();
    navigator.serviceWorker.controller.postMessage({
      type: "RESTART_POMODORO_TIMER",
    });
  }

  play() {
    var audio = document.getElementById("myAudio");
    audio.play();
  }

}
