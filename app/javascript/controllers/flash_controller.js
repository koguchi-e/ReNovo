import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.remove();
    }, 2000);
  }

  disconnect() {
    if (this.dismissTimer) clearTimeout(this.dismissTimer);
  }
}
