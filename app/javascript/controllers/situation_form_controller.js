import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step", "input", "error"];

  connect() {
    this.currentStep = 0;
    this.showCurrentStep();
  }

  next() {
    if (!this.validateCurrentStep()) return;
    this.currentStep++;
    this.showCurrentStep();
  }

  prev() {
    this.currentStep--;
    this.showCurrentStep();
  }

  submit(event) {
    if (!this.validateCurrentStep()) {
      event.preventDefault();
    }
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("hidden", index !== this.currentStep);
    });
  }

  clearError() {
    const error = this.errorTargets[this.currentStep];
    error.textContent = "";
    error.classList.add("hidden");
  }

  validateCurrentStep() {
    const input = this.inputTargets[this.currentStep];
    const error = this.errorTargets[this.currentStep];

    if (input.value.trim() === "") {
      error.textContent = "入力してください。";
      error.classList.remove("hidden");
      input.focus();
      return false;
    }

    if (input.value.length > 300) {
      error.textContent = "300文字以内にしてください。";
      error.classList.remove("hidden");
      input.focus();
      return false;
    }

    this.clearError();
    return true;
  }
}
