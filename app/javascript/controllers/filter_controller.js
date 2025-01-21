import { Controller } from "@hotwired/stimulus"
// const _ = require("lodash")

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = [ 
    "tabs", 
    "tabtitle",
    "content" 
  ]

  connect() {
    let that = this;
    //that.element.addEventListener('change', _.debounce(that.handleChange, 500))
  }

  selectTab(e){
    e.stopPropagation()
    this.tabtitleTargets.forEach(tab => { tab.classList.remove("border-sky-200", "font-medium", "text-sky-200"); tab.classList.add(
      "border-transparent", "text-gray-500"
    ); })
    this.tabsTargets.forEach(tab => { 
      if (tab.id == e.currentTarget.dataset.id) {
        e.currentTarget.classList.remove(
          "border-transparent", "text-gray-500"
        );
        e.currentTarget.classList.add(
          "border-sky-200", "font-medium", "text-sky-200"
        );
        tab.classList.remove("hidden") 
      } else {
        tab.classList.add("hidden") 
      }
    })
    // console.log(e)
    // console.log(e.currentTarget)
    // console.log(e.target)
    // console.log(e.currentTarget.dataset.id)
    // console.log(e.target.dataset.id)
    // console.log(this.element.dataset.id)
    // console.log(this.element)
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
