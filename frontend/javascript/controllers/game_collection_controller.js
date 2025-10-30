import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['gamesList', 'filtersButton', 'filterCheckbox'];

  static classes = ['gameCard', 'hidden'];

  connect() {
    this.filters = { letter: null, players: [] };
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

  #deactivateButton(button) {
    button.classList.remove('btn-primary');
    button.classList.add('btn-outline-primary');
  }

  #activateButton(button) {
    button.classList.remove('btn-outline-primary');
    button.classList.add('btn-primary');
  }

  async #applyFilters() {
    const selectors = [];
    if (this.filters.letter) {
      selectors.push(`[data-letter="${this.filters.letter}"]`);
    }
    if (this.filters.players.length > 0) {
      this.filters.players.forEach((number) => selectors.push(`[data-players="${number}"]`));
    }
    this.#showHiddenGameCards();
    this.#hideGameCards(selectors);
  }

  #showHiddenGameCards() {
    const selector = `.${this.gameCardClass}.${this.hiddenClass}`;
    this.gamesListTarget.querySelectorAll(selector).forEach((gameCard) => {
      gameCard.classList.remove(this.hiddenClass);
    });
  }

  #hideGameCards(selectors) {
    if (selectors.length === 0) return;

    const selector = `.${this.gameCardClass}:not(${selectors.join(', ')})`;
    this.gamesListTarget.querySelectorAll(selector).forEach((gameCard) => {
      gameCard.classList.add(this.hiddenClass);
    });
  }
}
