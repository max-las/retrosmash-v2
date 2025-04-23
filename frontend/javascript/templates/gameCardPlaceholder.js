export const gameCardPlaceholder = (game) => {
  return /*html*/`
    <div class="card game-card mb-3 placeholder-glow" aria-hidden="true">
      <div class="placeholder">
        <img src="${game.coverPath}" alt="placeholder" class="card-img-top invisible">
      </div>
      <div class="card-body">
        <h5 class="card-title">
          <span class="placeholder col-12"></span>
        </h5>
        <table class="table table-sm mb-0">
          <tr>
            <td><span class="placeholder col-6"></span></td>
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
      <td><span class="placeholder col-6"></span></td>
    </tr>
  `;
};
