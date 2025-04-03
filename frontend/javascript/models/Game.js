export class Game {
  constructor(data) {
    Object.assign(this, data);
  }

  get coverPath() {
    return `/images/consoles/${this.console_slug}/games/${this.slug}.webp`;
  }

  get coverAlt() {
    return `converture de ${this.title}`;
  }
}
