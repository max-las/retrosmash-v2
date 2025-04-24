import { Controller } from "@hotwired/stimulus";
import { db } from "../db";
import { Game } from "../models/Game";
import { gameCard } from "../templates/gameCard";

export default class extends Controller {
  static targets = ['gamesList'];

  static values = {
    collectionUrl: String,
    metadataUrl: String,
    consoleSlug: String
  };

  connect() {
    this.filters = {};
    this.#setActiveCollection();
    this.#fetchLatestCollection();
  }

  async #fetchLatestCollection() {
    this.metadata = await this.#fetchMetadata();

    const gameCollection = await this.#findOrCreateCollection();
    if (gameCollection.active) return;

    await db.gameCollections.update(gameCollection.id, { active: 1 });
    this.#setActiveCollection();
    this.#clearInactiveCollections();
  }

  async #findOrCreateCollection() {
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
    await this.#addGames(gameCollectionId);
    return await db.gameCollections.get(gameCollectionId);
  }

  async #addGames(gameCollectionId) {
    const games = await this.#fetchGames();
    await Promise.all(
      games.map((game) => {
        game.game_collection_id = gameCollectionId;
        return db.games.add(game);
      })
    );
  }

  async #fetchMetadata() {
    const response = await fetch(this.metadataUrlValue, { method: "GET", cache: 'no-store' });
    return await response.json();
  }

  async #fetchGames() {
    const response = await fetch(this.collectionUrlValue, { method: "GET", cache: 'no-store' });
    return await response.json();
  }

  async #clearInactiveCollections() {
    const inactiveCollectionIds =
      await db.gameCollections
              .where({ console_slug: this.consoleSlugValue, active: 0 })
              .primaryKeys();
    await Promise.all([
      db.gameCollections.where('id').anyOf(inactiveCollectionIds).delete(),
      db.games.where('game_collection_id').anyOf(inactiveCollectionIds).delete()
    ]);
  }

  async #setActiveCollection() {
    this.activeCollection = await db.gameCollections.get({
      console_slug: this.consoleSlugValue,
      active: 1
    });
  }

  filterByLetter(event) {
    const { letter } = event.params;
    const currentButton = event.currentTarget;
    if (this.filters.letter === letter) {
      this.#disableLetterButton(currentButton);
      delete this.activeLetterButton;
      delete this.filters.letter;
    } else {
      if (this.activeLetterButton) this.#disableLetterButton(this.activeLetterButton);
      this.#enableLetterButton(currentButton);
      this.activeLetterButton = currentButton;
      this.filters.letter = letter;
    }
    this.#applyFilters();
  }

  #disableLetterButton(button) {
    button.classList.remove('btn-primary');
    button.classList.add('btn-outline-primary');
  }

  #enableLetterButton(button) {
    button.classList.remove('btn-outline-primary');
    button.classList.add('btn-primary');
  }

  async #applyFilters() {
    const whereClause = { game_collection_id: this.activeCollection.id };
    if (this.filters.letter) whereClause.letter = this.filters.letter;
    const games = db.games.where(whereClause);
    await this.#renderGames(games);
  }

  async #renderGames(games) {
    this.gamesListTarget.style.setProperty("min-height", `${this.gamesListTarget.offsetHeight}px`);
    this.gamesListTarget.innerHTML = '';
    await games.each((gameData) => {
      const game = new Game({ ...gameData, console_slug: this.consoleSlugValue });
      const template = gameCard(game);
      this.gamesListTarget.insertAdjacentHTML('beforeend', template);
    });
    this.gamesListTarget.style.removeProperty("min-height");
  }
}
