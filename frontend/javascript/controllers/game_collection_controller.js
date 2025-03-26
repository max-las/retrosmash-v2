import { Controller } from "@hotwired/stimulus";
import { db } from "../db";

export default class extends Controller {
  static values = {
    collectionUrl: String,
    versionUrl: String,
    consoleSlug: String
  }

  connect() {
    this.syncCollection();
  }

  async syncCollection() {
    const version = await this.fetchVersion();
    const gameCollection = await db.gameCollections.get(this.consoleSlugValue);
    if (gameCollection && gameCollection.version === version) { return; }

    return await Promise.all([this.updateGameCollection(version), this.updateGames()]);
  }

  async updateGameCollection(version) {
    const newGameCollection = { console_slug: this.consoleSlugValue, version };
    return await db.gameCollections.put(newGameCollection);
  }

  async updateGames() {
    const [games] = await Promise.all([this.fetchGames(), this.clearGames()]);
    return await Promise.all(games.map((game) => this.addGame(game)));
  }

  async fetchVersion() {
    const response = await fetch(this.versionUrlValue, { method: "GET" });
    return await response.text();;
  }

  async fetchGames() {
    const response = await fetch(this.collectionUrlValue, { method: "GET" });
    return await response.json();
  }

  async clearGames() {
    return await db.games.where('console_slug').equals(this.consoleSlugValue).delete();
  }

  async addGame(game) {
    game.console_slug = this.consoleSlugValue;
    return await db.games.add(game);
  }
}
