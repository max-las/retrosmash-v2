export const gameCard = ({ title, consoleSlug, slug, players }) => {
  const coverPath = `/images/consoles/${consoleSlug}/games/${slug}.webp`;
  const coverAlt = `converture de ${title}`; 

  return /*html*/`
    <div class="card game-card mb-3">
      <img
        src="${coverPath}"
        class="card-img-top"
        alt="${coverAlt}">
      <div class="card-body">
        <h5 class="card-title fs-5 text-truncate">
          ${title}
        </h5>
        <p class="card-text">
          ${players} joueurs
        </p>
      </div>
    </div>
  `;
};
