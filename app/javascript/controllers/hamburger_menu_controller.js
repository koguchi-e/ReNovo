import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "menu"];

  toggle() {
    const shouldOpen = this.menuTarget.classList.contains("hidden");
    this.setOpen(shouldOpen);
  }

  closeOnOutside(event) {
    if (this.menuTarget.classList.contains("hidden")) return;
    if (this.menuTarget.contains(event.target)) return;
    if (this.buttonTarget.contains(event.target)) return;

    this.setOpen(false);
  }

  closeOnEscape(event) {
    if (this.menuTarget.classList.contains("hidden")) return;

    event.preventDefault();
    this.setOpen(false);
    this.buttonTarget.focus();
  }

  setOpen(isOpen) {
    this.menuTarget.classList.toggle("hidden", !isOpen);

    this.buttonTarget.setAttribute("aria-expanded", String(isOpen));
    this.buttonTarget.setAttribute(
      "aria-label",
      isOpen ? "メニューを閉じる" : "メニューを開く",
    );
  }
}
