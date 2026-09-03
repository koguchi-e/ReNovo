import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch } from "@rails/request.js";

export default class extends Controller {
  connect() {
    this.saving = false;

    this.sortable = Sortable.create(this.element, {
      handle: ".js-grab",

      onEnd: async (event) => {
        const oldIndex = event.oldIndex;
        this.updateRecommendation();

        try {
          this.saving = true;
          this.sortable.option("disabled", true);

          const url = event.item.dataset.taskUrl;
          const params = { insert_at: event.newIndex + 1 };

          const response = await patch(url, { body: params });

          if (!response.ok) {
            throw new Error("Failed to update task position");
          }
        } catch (error) {
          console.warn(error);
          const task = event.item;
          const siblings = Array.from(this.element.children).filter(
            (element) => element !== task,
          );
          const referenceElement = siblings[oldIndex] || null;
          this.element.insertBefore(task, referenceElement);
          this.updateRecommendation();
        } finally {
          this.saving = false;
          this.sortable.option("disabled", false);
        }
      },
    });
  }

  async moveUp(event) {
    if (this.saving) return;
    let task;
    let previousTask;

    try {
      task = event.currentTarget.closest("li");
      previousTask = task.previousElementSibling;

      if (!previousTask) return;
      this.saving = true;
      this.sortable.option("disabled", true);
      this.element.insertBefore(task, previousTask);
      this.updateRecommendation();

      const url = task.dataset.taskUrl;
      const insertAt = Array.from(this.element.children).indexOf(task) + 1;

      const response = await patch(url, {
        body: { insert_at: insertAt },
      });

      if (!response.ok) {
        throw new Error("Failed to update task position");
      }
    } catch (error) {
      console.warn(error);
      if (task && previousTask) {
        this.element.insertBefore(previousTask, task);
        this.updateRecommendation();
      }
    } finally {
      this.saving = false;
      this.sortable.option("disabled", false);
    }
  }

  async moveDown(event) {
    if (this.saving) return;
    let task;
    let nextTask;

    try {
      task = event.currentTarget.closest("li");
      nextTask = task.nextElementSibling;

      if (!nextTask) return;
      this.saving = true;
      this.sortable.option("disabled", true);
      this.element.insertBefore(nextTask, task);
      this.updateRecommendation();

      const url = task.dataset.taskUrl;
      const insertAt = Array.from(this.element.children).indexOf(task) + 1;

      const response = await patch(url, {
        body: { insert_at: insertAt },
      });

      if (!response.ok) {
        throw new Error("Failed to update task position");
      }
    } catch (error) {
      console.warn(error);
      if (task && nextTask) {
        this.element.insertBefore(task, nextTask);
        this.updateRecommendation();
      }
    } finally {
      this.saving = false;
      this.sortable.option("disabled", false);
    }
  }

  updateRecommendation() {
    const firstTaskContent = this.element.querySelector(
      "li:first-child [data-task-order-target='content']",
    );
    const recommendation = this.element.querySelector(
      "[data-task-order-target='recommendation']",
    );

    if (firstTaskContent && recommendation) {
      firstTaskContent.prepend(recommendation);
    }
  }
}
