import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 2000 },
  };

  connect() {
    this.timer = window.setTimeout(() => {
      Turbo.visit(window.location.href, { action: "replace" });
    }, this.intervalValue);
  }

  disconnect() {
    if (this.timer) {
      window.clearTimeout(this.timer);
    }
  }
}
