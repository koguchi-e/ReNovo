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

        try {
          this.saving = true;
          this.sortable.option("disabled", true);

          const url = event.item.dataset.taskPositionUrl;
          const params = {
            task_id: event.item.dataset.taskId,
            insert_at: event.newIndex + 1,
          };

          await patch(url, { body: params });
        } catch (error) {
          console.warn(error);
          const task = event.item;
          const siblings = Array.from(this.element.children).filter(
            (element) => element !== task,
          );
          const referenceElement = siblings[oldIndex] || null;
          this.element.insertBefore(task, referenceElement);
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

      const url = task.dataset.taskPositionUrl;
      const insertAt = Array.from(this.element.children).indexOf(task) + 1;

      await patch(url, {
        body: { task_id: task.dataset.taskId, insert_at: insertAt },
      });
    } catch (error) {
      console.warn(error);
      if (task && previousTask) {
        this.element.insertBefore(previousTask, task);
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

      const url = task.dataset.taskPositionUrl;
      const insertAt = Array.from(this.element.children).indexOf(task) + 1;

      await patch(url, {
        body: { task_id: task.dataset.taskId, insert_at: insertAt },
      });
    } catch (error) {
      console.warn(error);
      if (task && nextTask) {
        this.element.insertBefore(task, nextTask);
      }
    } finally {
      this.saving = false;
      this.sortable.option("disabled", false);
    }
  }
}
