import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "step",
    "input",
    "error",
    "output",
    "progressStep",
    "progressLabel",
    "factNextButton",
  ];

  connect() {
    this.currentStep = 0;
    this.showCurrentStep({ focus: false });
    this.updateFactNextButton();
  }

  next() {
    if (!this.validateCurrentStep()) return;
    this.currentStep++;
    this.showCurrentStep({ focus: true });
  }

  prev() {
    this.currentStep--;
    this.showCurrentStep({ focus: true });
  }

  submit(event) {
    if (!this.validateCurrentStep()) {
      event.preventDefault();
    }
  }

  showCurrentStep({ focus }) {
    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("hidden", index !== this.currentStep);
    });
    this.updateProgress();

    if (focus) {
      const heading = this.stepTargets[this.currentStep].querySelector("h2");
      heading.focus({ preventScroll: true });
      heading.scrollIntoView({
        behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches
          ? "auto"
          : "smooth",
        block: "start",
      });
    }
  }

  updateProgress() {
    this.progressStepTargets.forEach((progressStep, index) => {
      const isCurrent = index === this.currentStep;
      const isComplete = index < this.currentStep;

      progressStep.classList.toggle("bg-calm-blue", isCurrent || isComplete);
      progressStep.classList.toggle("text-white", isCurrent || isComplete);

      progressStep.classList.toggle("bg-gray-200", !isCurrent && !isComplete);
      progressStep.classList.toggle("text-gray-500", !isCurrent && !isComplete);
      progressStep.textContent = isComplete ? "✓" : String(index + 1);

      if (isCurrent) {
        progressStep.setAttribute("aria-current", "step");
      } else {
        progressStep.removeAttribute("aria-current");
      }
    });

    this.progressLabelTargets.forEach((progressLabel, index) => {
      const isCurrent = index === this.currentStep;

      progressLabel.classList.toggle("font-bold", isCurrent);
      progressLabel.classList.toggle("text-calm-blue", isCurrent);
      progressLabel.classList.toggle("font-normal", !isCurrent);
      progressLabel.classList.toggle("text-gray-600", !isCurrent);
    });
  }

  count(event) {
    this.updateCount(event.currentTarget);
    this.updateFactNextButton();
  }

  updateFactNextButton() {
    if (!this.hasFactNextButtonTarget) return;

    this.factNextButtonTarget.disabled = this.inputTargets[0].value.trim() === "";
  }

  updateCount(input) {
    const index = this.inputTargets.indexOf(input);
    const output = this.outputTargets[index];
    const length = input.value.length;
    output.textContent = length;
    output.classList.toggle("text-muted-error", length > 300);
    output.classList.toggle("font-bold", length > 300);
  }

  clearError() {
    const input = this.inputTargets[this.currentStep];
    const error = this.errorTargets[this.currentStep];
    error.textContent = "";
    error.classList.add("hidden");
    input.removeAttribute("aria-invalid");
  }

  validateCurrentStep() {
    const input = this.inputTargets[this.currentStep];
    const error = this.errorTargets[this.currentStep];

    if (input.value.trim() === "") {
      error.textContent = "入力してください。";
      error.classList.remove("hidden");
      input.setAttribute("aria-invalid", "true");
      input.focus();
      return false;
    }

    if (input.value.length > 300) {
      error.textContent = "300文字以内にしてください。";
      error.classList.remove("hidden");
      input.setAttribute("aria-invalid", "true");
      input.focus();
      return false;
    }

    this.clearError();
    return true;
  }
}
