import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition";

// Connects to data-controller="task"
export default class extends Controller {

  // Setup & Teardown ------------------------------------------------------  

  static targets = [
  ]

  static values = {
  }

  initialCustomer = "";
  initialProject = "";

  initialize() {
  }

  connect() {
    try {
      this.token = document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content");
      this.initialCustomer = document.querySelector(
        "#task_customer_id"
      )?.value || null;
      this.initialProject = document.querySelector(
        "#task_project_id"
      )?.value || null;
    } catch (e) {
      console.error("Error connecting TaskController:", e);
    }
  }

  disconnect() {
  }

  // Actions ---------------------------------------------------------------

  userChanged(e) {
  }

  customerChange(e) {
    let tmcid = document.querySelector("#task_customer_id");

    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
    } else {
      this.resetProjectInfo();
      if ( tmcid?.dataset?.lookupCustomerHourlyRate ) {
        console.log(`Setting customer hourly rate at ${tmcid.dataset.lookupCustomerHourlyRate}`);
        if (tmcid?.value !== this.initialCustomer) {
          this.initialCustomer = tmcid.value;
        }
      }
    }
  }

  resetProjectInfo() {
    try {
      document.querySelector("#task_project_id").value = "";
      document.querySelector("#task_project_name").value = "";
      document.querySelector("#task_project_id").dataset.lookupCustomerId = "";
      document.querySelector("#task_project_id").dataset.lookupCustomerName = "";
      document.querySelector("#task_project_id").dataset.lookupProjectHourlyRate = "";
    } catch (error) {
      console.error("Error resetting project info:", error);
    }
  } 

  projectChange(e) {
    let tmcid = document.querySelector("#task_customer_id");
    let tmpid = document.querySelector("#task_project_id");
    if (!tmpid || !tmcid) return;

    if (e.currentTarget.value === "") {
      e.target.previousSibling.value = "";
      return
    }
    if (tmpid.dataset.lookupCustomerName) {
      tmcid.value = tmpid.dataset.lookupCustomerId;
      document.querySelector("#task_customer_name").value = tmpid.dataset.lookupCustomerName;
      if ( tmpid.dataset.lookupProjectHourlyRate ) {
        if (tmpid.value !== this.initialProject) {
          this.initialProject = tmpid.value;
        }        
      }
    }
  }

  toggleOptions(e) {
    const options = this.lookupOptionsTarget;
    if (options.classList.contains("hidden")) {
      options.classList.remove("hidden");
      this.items_connected = true;
      this.optionsListTarget.getElementsByTagName("LI")[0].focus();
    } else {
      options.classList.add("hidden");
      this.items_connected = false;
    }
  }
}
