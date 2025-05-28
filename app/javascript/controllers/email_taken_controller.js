import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="email-taken"
export default class extends Controller {
  static targets = [ 
    "email",
    "emailTakenMessage"
  ]

  connect() {
    console.log('connected')
  }

  validate(event) {
    const email = event.target.value
    fetch(`/tenants/registrations.json?email=${email}`)
      .then(response => response.json())
      .then(data => {
        this.emailTakenMessageTarget.textContent = data.email
        if (data.name != "") {
          this.emailTakenMessageTarget.style.color = "red";
        } else {
          this.emailTakenMessageTarget.style.color = "green";
        }
      })
  }
}
