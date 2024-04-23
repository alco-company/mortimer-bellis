import { Controller } from "@hotwired/stimulus"
// const _ = require("lodash")

// Connects to data-controller="filter"
export default class extends Controller {

  connect() {
    let that = this;
    console.log( this.element.closest('filter-container') )
    //that.element.addEventListener('change', _.debounce(that.handleChange, 500))
  }

  hide(){
    console.log(`element: ${this.element.dataset.id}`)
    this.element.closest("filter-container").innerHTML = ""
  }

  handleChange(event) {
    event.preventDefault()
    // event.target.name // => "user[answer]"
    // event.target.value // => <user input string>
    event.target.form.requestSubmit()
  }
}
