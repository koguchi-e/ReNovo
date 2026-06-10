import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step"];
  connect() {
    this.currentStep = 0;
    this.showCurrentStep();
  }

  next() {
    this.currentStep++;
    this.showCurrentStep();
  }

  prev() {
    this.currentStep--;
    this.showCurrentStep();
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("hidden", index !== this.currentStep);
    });
  }
}
