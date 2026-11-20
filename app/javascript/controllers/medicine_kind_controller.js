import { Controller } from "@hotwired/stimulus"

// Shows the fields that belong to the chosen kind of medicine.
export default class extends Controller {
  static targets = ["select", "asNeeded", "scheduled"]

  connect() { this.toggle() }

  toggle() {
    const scheduled = this.selectTarget.value === "scheduled"
    this.asNeededTarget.hidden = scheduled
    this.scheduledTarget.hidden = !scheduled
  }
}
