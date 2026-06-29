import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display", "form", "button", "createForm"];

  edit() {
    this.displayTarget.classList.add("hidden");
    this.formTarget.classList.remove("hidden");
  }

  cancel() {
    this.formTarget.classList.add("hidden");
    this.displayTarget.classList.remove("hidden");
  }

  create() {
    this.buttonTarget.classList.add("hidden");
    this.createFormTarget.classList.remove("hidden");
  }
}
