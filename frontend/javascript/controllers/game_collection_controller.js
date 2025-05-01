import { Controller } from "@hotwired/stimulus";
import { db } from "../db";
import { Game } from "../models/Game";
import { gameCard } from "../templates/gameCard";

export default class extends Controller {
  static targets = [
    'gamesList',
    'filtersButton',
    'filterCheckbox',
    'gamePlaceholderTemplate',
    'gamePlaceholder',
  ];

  static values = {
    collectionUrl: String,
    firstChunkUrl: String,
    chunkSize: Number,
    metadataUrl: String,
    consoleSlug: String
  };

  async connect() {
    this.filters = { letter: null, players: [] };
    await Promise.all([this.#fetchMetadata(), this.#setActiveCollection()]);
    if (this.activeCollection) {
      const games = db.games.where({ game_collection_id: this.activeCollection.id });
      this.#renderGamesFromCollection(games);
    } else {
      this.#loadNextChunk();
    }
    this.#fetchLatestCollection();
  }

  filterByLetter(event) {
    const { letter } = event.params;
    const currentButton = event.currentTarget;
    if (this.filters.letter === letter) {
      this.#deactivateButton(currentButton);
      delete this.activeLetterButton;
      delete this.filters.letter;
    } else {
      if (this.activeLetterButton) this.#deactivateButton(this.activeLetterButton);
      this.#activateButton(currentButton);
      this.activeLetterButton = currentButton;
      this.filters.letter = letter;
    }
    this.#applyFilters();
  }

  applyPlayersFilters() {
    this.#forceBackupFilterCheckboxes();

    this.filters.players = [];
    this.filterCheckboxTargets.forEach((checkbox) => {
      if (checkbox.checked) {
        const players = parseInt(checkbox.dataset.gameCollectionPlayersParam);
        this.filters.players.push(players);
      }
    });

    if (this.filters.players.length > 0) {
      this.#activateButton(this.filtersButtonTarget);
    } else {
      this.#deactivateButton(this.filtersButtonTarget);
    }

    this.#applyFilters();
  }

  backupFilterCheckboxes() {
    if (this.filterCheckboxesBackup) return;

    this.#forceBackupFilterCheckboxes();
  }

  #forceBackupFilterCheckboxes() {
    this.filterCheckboxesBackup = new Map();
    this.filterCheckboxTargets.forEach((checkbox) => {
      this.filterCheckboxesBackup.set(checkbox, checkbox.checked);
    });
  }

  restoreFilterCheckboxes() {
    this.filterCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = this.filterCheckboxesBackup.get(checkbox);
    });
  }

  monitorScrollForChunks() {
    if (!this.chunksEnabled) return;

    const threshold = 200;
    const scroll = window.scrollY + window.innerHeight;
    if (scroll >= document.body.scrollHeight - threshold) {
      this.#loadNextChunk();
    }
  }

  async #loadNextChunk() {
    this.chunksEnabled = false;
    this.#appendPlaceholders();
    const chunkToLoad = this.lastLoadedChunk ? this.lastLoadedChunk + 1 : 0;
    const response = await fetch(this.#chunkUrl(chunkToLoad), { method: "GET" });
    const games = await response.json();
    this.#clearPlaceholders();
    this.#appendGamesFromChunk(games);
    this.lastLoadedChunk = chunkToLoad;
    this.chunksEnabled = this.lastLoadedChunk < this.metadata.chunks - 1;
  }

  async #fetchLatestCollection() {
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
    const games = await this.#fetchAllGames();
    await Promise.all(
      games.map((game) => {
        game.game_collection_id = gameCollectionId;
        return db.games.add(game);
      })
    );
  }

  async #fetchMetadata() {
    const response = await fetch(this.metadataUrlValue, { method: "GET", cache: 'no-store' });
    this.metadata = await response.json();
    this.chunksEnabled = !this.activeCollection;
  }

  async #fetchAllGames() {
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

  #deactivateButton(button) {
    button.classList.remove('btn-primary');
    button.classList.add('btn-outline-primary');
  }

  #activateButton(button) {
    button.classList.remove('btn-outline-primary');
    button.classList.add('btn-primary');
  }

  async #applyFilters() {
    const whereClause = { game_collection_id: this.activeCollection.id };
    if (this.filters.letter) {
      whereClause.letter = this.filters.letter;
    }
    const games = db.games.where(whereClause);
    if (this.filters.players.length > 0) {
      games.filter((gameData) => this.filters.players.includes(gameData.players));
    }
    await this.#renderGamesFromCollection(games);
  }

  async #renderGamesFromCollection(games) {
    this.gamesListTarget.style.setProperty("min-height", `${this.gamesListTarget.offsetHeight}px`);
    this.gamesListTarget.innerHTML = '';
    await games.each(this.#renderGame.bind(this));
    this.gamesListTarget.style.removeProperty("min-height");
  }

  #appendGamesFromChunk(games) {
    games.forEach(this.#renderGame.bind(this));
  }

  #renderGame(gameData) {
    const game = new Game({ ...gameData, console_slug: this.consoleSlugValue });
    const template = gameCard(game);
    this.gamesListTarget.insertAdjacentHTML('beforeend', template);
  }

  #chunkUrl(chunk) {
    return this.firstChunkUrlValue.replace(/0(?!.*0)/g, chunk);
  }

  #appendPlaceholders() {
    for (let i = 0; i < this.chunkSizeValue; i++) {
      this.gamesListTarget.insertAdjacentHTML(
        'beforeend',
        this.gamePlaceholderTemplateTarget.innerHTML
      );
    }
  }

  #clearPlaceholders() {
    this.gamePlaceholderTargets.forEach((placeholder) => { placeholder.remove(); });
  }
}
