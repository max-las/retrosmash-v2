export const gameCard = (game) => {
  return /*html*/`
    <div class="card game-card mb-3">
      <img
        src="${game.coverPath}"
        class="card-img-top"
        alt="${game.coverAlt}">
      <div class="card-body">
        <h5 class="card-title fs-5 text-truncate">
          ${game.title}
        </h5>
        <p class="card-text">
          ${game.players} joueurs
        </p>
      </div>
    </div>
  `;
};
