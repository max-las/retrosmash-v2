export const gameCard = (game) => {
  const gameCard = document.getElementById('game-card-template').content.cloneNode(true);

  const cover = grab(gameCard, 'cover');
  cover.src = game.coverPath;
  cover.alt = game.coverAlt;

  insert(gameCard, 'title', game.title);
  insert(gameCard, 'players', game.players);
  insertPegi(gameCard, game);

  return gameCard;
};

const insertPegi = (gameCard, game) => {
  if (!game.pegi) return;

  const pegi = document.getElementById('game-card--pegi-template').content.cloneNode(true);
  insert(pegi, 'pegi', game.pegi);
  insert(gameCard, 'pegi', pegi);
};

const insert = (parent, slotName, content) => {
  const slot = parent.querySelector(`[data-slot="${slotName}"]`);
  slot.append(content);
};

const grab = (parent, partName) => parent.querySelector(`[data-handle="${partName}"]`);
