import { Controller } from "@hotwired/stimulus";
import { Tooltip } from "bootstrap";

export default class extends Controller {
  static values =  { title: String };

  connect() {
    this.tooltip = new Tooltip(this.element, this.#options);
  }

  get #options() {
    return { title: this.titleValue };
  }
}
