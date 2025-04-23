import { Controller } from "@hotwired/stimulus";
import { db } from "../db";

export default class extends Controller {
  static values = {
    collectionUrl: String,
    metadataUrl: String,
    consoleSlug: String
  };

  connect() {
    this.setActiveCollection();
    this.fetchLatestCollection();
  }

  async fetchLatestCollection() {
    this.metadata = await this.fetchMetadata();

    const gameCollection = await this.findOrCreateCollection();
    if (gameCollection.active) return;

    await db.gameCollections.update(gameCollection.id, { active: 1 });
    this.setActiveCollection();
    this.clearInactiveCollections();
  }

  async findOrCreateCollection() {
    const gameCollection = await db.gameCollections.get({
      console_slug: this.consoleSlugValue,
      version: this.metadata.version
    });
    if (gameCollection) return gameCollection;

    const gameCollectionId = await db.gameCollections.add({
      console_slug: this.consoleSlugValue,
      version: this.metadata.version,
      active: 0
    });
    await this.addGames(gameCollectionId);
    return await db.gameCollections.get(gameCollectionId);
  }

  async addGames(gameCollectionId) {
    const games = await this.fetchGames();
    await Promise.all(
      games.map((game) => {
        game.game_collection_id = gameCollectionId;
        return db.games.add(game);
      })
    );
  }

  async fetchMetadata() {
    const response = await fetch(this.metadataUrlValue, { method: "GET", cache: 'no-store' });
    return await response.json();
  }

  async fetchGames() {
    const response = await fetch(this.collectionUrlValue, { method: "GET", cache: 'no-store' });
    return await response.json();
  }

  async clearInactiveCollections() {
    const inactiveCollectionIds =
      await db.gameCollections
              .where({ console_slug: this.consoleSlugValue, active: 0 })
              .primaryKeys();
    await Promise.all([
      db.gameCollections.where('id').anyOf(inactiveCollectionIds).delete(),
      db.games.where('game_collection_id').anyOf(inactiveCollectionIds).delete()
    ]);
  }

  async setActiveCollection() {
    this.activeCollection = await db.gameCollections.get({
      console_slug: this.consoleSlugValue,
      active: 1
    });
  }
}
