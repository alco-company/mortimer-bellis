import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-strength"
export default class extends Controller {
  static targets = [ 
    "password", 
    "strengthIndicator" 
  ]

  connect() {
    try {
      if (this.passwordTarget)
        this.updateStrength();
    } catch (error) { }
  }


  updateStrength() {
    const { row, column } = this.getEstimatedCrackTime()
    const message = `Password could be cracked in ${this.passwordStrengthResults[row][column]}`
    this.strengthIndicatorTarget.textContent = message
    this.strengthIndicatorTarget.style.color = this.passwordStrengthColors[row][column]
  }

  getEstimatedCrackTime() {
    const password = this.passwordTarget.value
    const length = password.length
    const hasLowercase = /[a-z]/.test(password)
    const hasUppercase = /[A-Z]/.test(password)
    const hasNumbers = /[0-9]/.test(password)
    const hasSymbols = /[\W_]/.test(password)

    let column = 1
    if (hasLowercase) column = 2
    if (hasLowercase && hasUppercase) column = 3
    if (hasLowercase && hasUppercase && hasNumbers) column = 4
    if (hasLowercase && hasUppercase && hasNumbers && hasSymbols) column = 5

    const row = length > 18 ? 18 : length

    return {
      row: row, column: column
    }
  }

  passwordStrengthResults = [
    [0, "instantly", "instantly", "instantly", "instantly", "instantly"],
    [1, "instantly", "instantly", "instantly", "instantly", "instantly"],
    [2, "instantly", "instantly", "instantly", "instantly", "instantly"],
    [3, "instantly", "instantly", "instantly", "instantly", "instantly"],
    [4, "instantly", "instantly", "3 secs", "6 secs", "9 secs"],
    [5, "instantly", "4 secs", "2 mins", "6 mins", "10 mins"],
    [6, "instantly", "2 mins", "2 hours", "6 hours", "12 hours"],
    [7, "4 secs", "50 mins", "4 days", "2 weeks", "1 month"],
    [8, "37 secs", "22 hours", "8 months", "3 years", "7 years"],
    [9, "6 mins", "3 weeks", "33 years", "161 years", "479 years"],
    [10, "1 hour", "2 years", "1k years", "9k years", "33k years"],
    [11, "10 hours", "44 years", "89k years", "618k years", "2m years"],
    [12, "4 days", "1k years", "4m years", "38m years", "164m years"],
    [13, "1 month", "29k years", "241m years", "2bn years", "11bn years"],
    [14, "1 year", "766k years", "12bn years", "147bn years", "805bn years"],
    [15, "12 years", "19m years", "652bn years", "9tn years", "56tn years"],
    [16, "119 years", "517m years", "33tn years", "566tn years", "3qd years"],
    [17, "1k years", "13bn years", "1qd years", "35qd years", "276qd years"],
    [18, "11k years", "350bn years", "91qd years", "2qn years", "19qn years"],
  ]

  passwordStrengthColors = [
    [0, "purple", "purple", "purple", "purple", "purple"],
    [1, "purple", "purple", "purple", "purple", "purple"],
    [2, "purple", "purple", "purple", "purple", "purple"],
    [3, "purple", "purple", "purple", "purple", "purple"],
    [4, "purple", "purple", "red", "red", "red"],
    [5, "purple", "red", "red", "red", "red"],
    [6, "purple", "red", "red", "red", "red"],
    [7, "red", "red", "red", "red", "red"],
    [8, "red", "red", "red", "orange", "orange"],
    [9, "red", "red", "orange", "orange", "orange"],
    [10, "red", "orange", "orange", "orange", "orange"],
    [11, "red", "orange", "orange", "orange", "orange"],
    [12, "red", "orange", "orange", "orange", "orange"],
    [13, "red", "orange", "orange", "orange", "darkgreen"],
    [14, "red", "orange", "darkgreen", "darkgreen", "darkgreen"],
    [15, "orange", "orange", "darkgreen", "darkgreen", "darkgreen"],
    [16, "orange", "orange", "darkgreen", "darkgreen", "darkgreen"],
    [17, "orange", "darkgreen", "darkgreen", "darkgreen", "darkgreen"],
    [18, "orange", "darkgreen", "darkgreen", "darkgreen", "darkgreen"],
  ]
}
