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
        <table class="table table-sm mb-0">
          <tr>
            <td>${game.players} joueurs</td>
          </tr>
          ${pegi(game)}
        </table>
      </div>
    </div>
  `;
};

const pegi = (game) => {
  if (!game.pegi) { return ''; }

  return /*html*/`
    <tr>
      <td>PEGI ${game.pegi}</td>
    </tr>
  `;
};
