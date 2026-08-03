import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 2000 },
  };

  connect() {
    this.scheduledVisit();
  }

  disconnect() {
    this.cancelScheduledVisit();
  }

  scheduledVisit() {
    this.timer = window.setTimeout(() => {
      this.scheduledVisit();
      Turbo.visit(window.location.href, { action: "replace" });
    }, this.intervalValue);
  }

  cancelScheduledVisit() {
    if (this.timer) {
      window.clearTimeout(this.timer);
      this.timer = null;
    }
  }
}
