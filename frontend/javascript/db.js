import Dexie from 'dexie';

Dexie.debug = true; // TODO

export const db = new Dexie('retrosmash');

db.version(1).stores({
  gameCollections: '++id, [console_slug+version], [console_slug+active]',
  games: '[game_collection_id+slug], game_collection_id, [game_collection_id+letter]'
});
