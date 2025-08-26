import { Application } from "@hotwired/stimulus"
import LiveSearchController from "./live_search_controller"

window.Stimulus = window.Stimulus || Application.start()
window.Stimulus.register("live-search", LiveSearchController)
