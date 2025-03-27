import Dexie from 'dexie';

export const db = new Dexie('retrosmash');

db.version(1).stores({
  gameCollections: 'version, [console_slug+active]',
  games: '[game_collection_version+slug], game_collection_version, players'
});
