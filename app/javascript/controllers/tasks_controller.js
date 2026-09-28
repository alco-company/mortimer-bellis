import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  toggle(event) {
    const checkbox = event.target
    const taskId = checkbox.id.replace('task_', '')
    const completed = checkbox.checked

    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        task: {
          completed_at: completed ? new Date().toISOString() : null
        }
      })
    })
  }

  submit(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      event.target.closest('form').requestSubmit()
    }
  }
}
