import Dexie from 'dexie';

export const db = new Dexie('retrosmash');

db.version(1).stores({
  game_collections: 'console_slug',
  games: '[console_slug+slug], console_slug, players'
});
