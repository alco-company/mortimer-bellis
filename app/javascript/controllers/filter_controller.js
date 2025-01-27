import { Controller } from "@hotwired/stimulus"
// const _ = require("lodash")

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = [ 
    "tabs", 
    "tabtitle",
    "dateRange",
    "content",
    "input", 
    "selector"
  ]

  connect() {
    let that = this;
    //that.element.addEventListener('change', _.debounce(that.handleChange, 500))
  }

  toggleAssociationFieldList(e){
    e.stopPropagation()
    e.preventDefault()
    e.currentTarget.getElementsByTagName("svg")[0].classList.toggle("rotate-90")
    let list = e.currentTarget.dataset.list
    document.getElementById(list).classList.toggle("hidden")
  }

  selectTab(e){
    e.stopPropagation()
    this.tabtitleTargets.forEach(tab => { tab.classList.remove("border-sky-200", "font-medium", "text-sky-600"); tab.classList.add(
      "border-transparent", "text-gray-500"
    ); })
    this.tabsTargets.forEach(tab => { 
      if (tab.id == e.currentTarget.dataset.id) {
        e.currentTarget.classList.remove(
          "border-transparent", "text-gray-500"
        );
        e.currentTarget.classList.add(
          "border-sky-200", "font-medium", "text-sky-600"
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

  // setDate
  //
  setDate(e){
    e.stopPropagation()
    e.preventDefault()
    let range = e.currentTarget.dataset.range
    this.dateRangeTargets.forEach(dateRange => { dateRange.classList.remove("bg-sky-100", "font-medium", "text-sky-600"); dateRange.classList.add("bg-white", "text-gray-500"); })
    e.currentTarget.classList.remove("bg-white", "text-gray-500"); e.currentTarget.classList.add("bg-sky-100", "font-medium", "text-sky-600")
    document.getElementById("filter_date_fixed_range").value = range;
  }

  clearFixedRange(e){
    this.dateRangeTargets.forEach((dateRange) => {
      dateRange.classList.remove("bg-sky-100", "font-medium", "text-sky-600");
      dateRange.classList.add("bg-white", "text-gray-500");
    });
    document.getElementById("filter_date_fixed_range").value = "";
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

  async submitField(e){
    e.stopPropagation();
    e.preventDefault()
    let se = this.selectorTarget
    let selected = se.options[se.selectedIndex].value
    let url = `filter_fields?field=${this.inputTarget.name}&value=${this.inputTarget.value}&selected=${selected}`
    const response = await fetch(url, {
      method: "GET",
      // body: JSON.stringify({ promo_code: this.promoCodeTarget.value }),
      headers: { Accept: "text/vnd.turbo-stream.html" }
    });

    if (response.status === 204) {
      return true;
    } else {
      const text = await response.text();
      Turbo.renderStreamMessage(text);
    }
  }
}
