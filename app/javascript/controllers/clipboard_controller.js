import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source", "icon", "message"];

  async copy() {
    const text = this.sourceTarget.innerText;

    try {
      await navigator.clipboard.writeText(text);
      this.iconTarget.hidden = true;
      this.messageTarget.hidden = false;
      setTimeout(() => {
        this.iconTarget.hidden = false;
        this.messageTarget.hidden = true;
      }, 2000);
    } catch (error) {
      console.error("コピーに失敗しました", error);
    }
  }
}
