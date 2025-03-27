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
    const gameCollection = await findOrCreateCollection(version);
    if (gameCollection.active) { return; }

    await db.gameCollections.update(version, { active: true });
    clearInactiveCollections();
  }

  async findOrCreateCollection(version) {
    const gameCollection = await db.gameCollections.get(version);
    if (gameCollection) { return gameCollection; }

    const [newGameCollection] = await Promise.all([
      this.addCollection(version),
      this.addGames(version)
    ]);
    return newGameCollection;
  }

  async addCollection(version) {
    await db.gameCollections.add({
      version,
      console_slug: this.consoleSlugValue,
      active: false
    });
  }

  async addGames(version) {
    const games = await this.fetchGames();
    await Promise.all(games.map((game) => this.addGame(game, version)));
  }

  async fetchVersion() {
    const response = await fetch(this.versionUrlValue, { method: "GET" });
    return await response.text();
  }

  async fetchGames() {
    const response = await fetch(this.collectionUrlValue, { method: "GET" });
    return await response.json();
  }

  async clearInactiveCollections() {
    const inactiveVersions = await db.gameCollections.where({ active: false }).primaryKeys();
    await Promise.all([
      db.gameCollections.where('version').anyOf(inactiveVersions).delete(),
      db.games.where('game_collection_version').anyOf(inactiveVersions).delete()
    ])
  }

  async addGame(game, version) {
    game.game_collection_version = version
    game.console_slug = this.consoleSlugValue;
    await db.games.add(game);
  }

  async getActiveCollection() {
    return await db.gameCollections.get({ console_slug: this.consoleSlugValue, active: true });
  }
}
