import { Controller } from "@hotwired/stimulus";
import { Tooltip } from "bootstrap";

export default class extends Controller {
  static values =  {
    title: String,
    placement: String
  };

  connect() {
    this.tooltip = new Tooltip(this.element, this.#options);
  }

  get #options() {
    const options = { title: this.titleValue };
    if (this.hasPlacementValue) options.placement = this.placementValue;

    return options;
  }
}
