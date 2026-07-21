import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch } from "@rails/request.js";

export default class extends Controller {
  connect() {
    Sortable.create(this.element, {
      handle: ".js-grab",

      onEnd(event) {
        const url = event.item.dataset.taskPositionUrl;
        const params = {
          task_id: event.item.dataset.taskId,
          insert_at: event.newIndex + 1,
        };

        patch(url, { body: params }).catch((error) => {
          console.warn(error);
        });
      },
    });
  }
}
