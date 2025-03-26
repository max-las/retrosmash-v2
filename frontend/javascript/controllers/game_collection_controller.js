import { Controller } from "@hotwired/stimulus";
import { db } from "../db";

export default class extends Controller {
  static values = {
    collectionUrl: String,
    versionUrl: String
  }

  connect() {
    this.fetchVersion();
  }

  async fetchVersion() {
    const response = await fetch(this.versionUrlValue, { method: "GET" });
    const version = await response.text();
    console.log(version);
  }
}
