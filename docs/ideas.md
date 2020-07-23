# Raw dump of ideas, losely categorized

## Puzzles or dungeon features
- electric generators and fuel or batteries, work as locks and keys to power up an electric puzzle. There could be one per room, or one that powers every circuit or power outlet in a dungeon.
- "light the candles" puzzles that span a whole dungeon. For singleplayer, those candles or torches would be lit forever, but in multiplayer games they would turn off on a timer that depends on the number of players

## Enemies and traps
- electric beamos, a stationary rotating eye with laser beams enemy/trap, that only works when powered up. Might float when powered and collapse to the ground without power? Can be used as a defense that has to be disabled, or to spice up a room when it sits on a wire you need to power up to advance to the next room.
- guards and alerters. Soldiers holding a position or patrolling a fixed route, will chase a player that walks into sight and have them respawn at the entrance and walk back to its guard position afterwards (if there is a player in the room). Alerters are targets a player can activate with bombs or bomb arrows to lure guards from their posts and sneak through unnoticed.

## Rings and equipment
- there are a number of rings to be collected, but only one can be equipped at a time, each player can chose which one to wear.
- ring of summon metal crate. The crate could be used to temporarily block a narrow passage, to bridge a gap in electrical wires or to bridge a narrow chasm without a Roc's feather. The crate will despawn on a timer and has a cooldown.
- sonar ring, to help traverse dark rooms. Does either a slow moving sweep that faintly lights up along the beam for a short time, or moves like a water ripple, a growing ring that provides a small light source for tiles below the ring. Is it possible to have screen space shaders that use the collision maps of the tiles? Bat ring?
- sound detector ring. When equipped, it shows a sound wave cloud around moving objects in dark rooms. Make impacts of (bomb)arrows visible as well?
- fire fairy, to be kept in a bottle and released in dark rooms. buzzes off into the direction you are attacking with your A button, providing a small light to scout ahead. Travels in straight lines until a barrier is encountered. Has to be bottled up again before you leave the room or it is gone. Can be bottled by other players?

## Game options or general features
- have players chose a color along with their character sprite and name. That color is used as a shadow beneath that player on other player's screens.
- have one color in a player sprite change according to the level of armor the player has equipped as visual feedback
- have new items cloned to every players inventory on pickup, but each player keeps their own ammo count. Same applies to bottles: once a bottle is picked up, each player gets a copy, but can use and restock it independently.
- would it be possible to have some kind of "weak spot" overlay for bosses, that players can chose to see as a means of difficulty setting?
- "cave of ordeals" type pure combat dungeon, where the player can only advance to a new room, but not back to a previous room. Mobs do not drop items! Provides small prizes like different amounts of coins or pieces of heart after a number of rooms. Could also be made available from the start screen, where players pick their gear and compete for completion time highscores. Gear selection includes number of hearts or armor types, so players could do challenge runs with just three hearts and the likes.

## Randomizer
- randomizer: fake items to allow for harder modes or glitches to be taken into consideration at loot distribution. For example, chests in or after a dark room would work on a "lamp ||  firerod || darkroomtraversal", where "darkroomtraversal" would be a skill, not an item. It would still be provided to the randomizer as part of the starting equipment, so the randomizer identifies those locations as accessible even if the player does not have a lamp or fire rod. She is simply able to finish dark rooms blindly and can reach those locations. The lamp, fire rod, sonar ring, sound detector ring or fire fairy would trigger this fake item for the randomizer as well. So as soon as one of those real items is picked up, the "darkroomtraversal" trait gets set. Lamps and fire rod would also set a "firesource" fake item, that would make for easier conditions, e.g. on "light the candle(s) puzzles.
- randomized "cave of ordeals". Prizes after a certain number of rooms would be fixed, but room layout and mob loadout could be randomized.
- swap out selected rooms in each dungeon to bring a bit of variety to players doing lots of runs. Replacement rooms do not change the dungeon requirements or overall pathing, they are just a variation of the room layout.
