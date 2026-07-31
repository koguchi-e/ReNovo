import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "menu"];

  toggle() {
    const isOpen = !this.menuTarget.classList.toggle("hidden");

    this.buttonTarget.setAttribute("aria-expanded", String(isOpen));
    this.buttonTarget.setAttribute(
      "aria-label",
      isOpen ? "メニューを閉じる" : "メニューを開く",
    );
  }
}
