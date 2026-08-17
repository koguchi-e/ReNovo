import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog"];

  open() {
    this.dialogTarget.showModal();
  }

  close() {
    this.dialogTarget.close();
  }

  closeOnBackdrop(event) {
    const bounds = this.dialogTarget.getBoundingClientRect();
    const clickedOutside =
      event.clientX < bounds.left ||
      event.clientX > bounds.right ||
      event.clientY < bounds.top ||
      event.clientY > bounds.bottom;

    if (clickedOutside) this.close();
  }
}
