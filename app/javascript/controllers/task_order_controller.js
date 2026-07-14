import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["list", "item", "hiddenFields"];

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
    });
    this.element.addEventListener("submit", this.buildHiddenFields.bind(this));
  }

  buildHiddenFields() {
    this.hiddenFieldsTarget.innerHTML = "";
    this.itemTargets.forEach((item) => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "task_ids[]";
      input.value = item.dataset.id;
      this.hiddenFieldsTarget.appendChild(input);
    });
  }
}
