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
        const players = checkbox.dataset.players;
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
    this.#showHiddenGameCards();
    this.#hideGameCardsNotMatchingFilters();
  }

  #showHiddenGameCards() {
    const selector = `.${this.gameCardClass}.${this.hiddenClass}`;
    this.gamesListTarget.querySelectorAll(selector).forEach((gameCard) => this.#show(gameCard));
  }

  #hideGameCardsNotMatchingFilters() {
    this.gamesListTarget.querySelectorAll(`.${this.gameCardClass}`).forEach((gameCard) => {
      if (this.filters.letter) {
        if (this.filters.letter !== gameCard.dataset.letter) {
          return this.#hide(gameCard);
        }
      }
      if (this.filters.players.length > 0) {
        if (!this.filters.players.includes(gameCard.dataset.players)) {
          return this.#hide(gameCard);
        }
      }
    });
  }

  #hide(element) {
    element.classList.add(this.hiddenClass);
  }

  #show(element) {
    element.classList.remove(this.hiddenClass);
  }
}
