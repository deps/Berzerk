TODO:

Period 1: Oct 7 to Oct 14 - 11 sessions (41 in total)
- Draw graphics for the maze
--- floor (code added but not used)

- Player can shoot
--- Press the fire button and select direction
--- Player is standing still when the button is pressed.

- Code for recording game play movies.
--- Save time for key press and release
--- Saves the time for when recording ended.
- Code for control the player using a recording.
--- Game play ends when recording did.
- Refactor!
 
Period 2: Oct 14 to Oct 21 - 14 sessions (41 in total)
- Draw droids
--- 4 direction animation, 4 frame idle animation with scanning eye
- Droids added to the room
--- Randomly placed, using the same seed as the walls of the maze
- Droids can move
- Droid can bump into walls, or each other, and explode
- Droid - player collisions
- Droids can shoot
--- Just a placeholder until score is added
 
- Bullets are removed if touching a wall
- Bullets kills player and droids
 
- Draw Evil Otto
--- needs only one frame. Might add another for the bounce
- Evil Otto appears after a time limit
--- Spawns where player started in the room
- Evil Otto moves towards the player
- Bullets are removed if touching Evil Otto
- Evil Otto destroys droids and player if he touches them
- Refactor!
 
Period 3: Oct 21 to Oct 28 - 8 sessions (41 in total)
- Speech added when leaving a room
--- Record the words one by one, and play them together in the game. Words will be needed later when droids are talking
 
- Talking droid sounds added
- The message spoken is visualized by a scroller at the bottom of the screen.
- Scores added
- Change droid color and firing ability based on score:
0-260	Yellow	No bullets
260-1,200	Red	1
1,200-3,000	Light Blue	2
3,000-4,500	Light Green	3
4,500-6,000	Purple	4
6,000-8,000	Yellow	5
8,000-10,000	White	1 fast shot (2x speed)
10,000-12,000+	Light Blue	Two fast shots
- Player death added
- High score list added and name entry
--- Only use name entry if score was high enough to be on the list
- Refactor!
 
Period 4: Oct 28 to Oct 31 - 8 sessions (41 in total)
- Attract mode title screen added
- Sounds for attract mode added: "Coin detected in pocket". Played when title screen is displayed.
- Game play example added to attract mode. Recorded earlier by my playing it. Ends with player death. No sounds during attract mode. A random playback selected from multiple ones.
- Attract mode shows high score list after game play example.
- Credit screen added to attract mode. Shown after high score list. Returns to title screen.
- Background "music" added to attract mode. Different from game play music.
- Refactor!
- Eat cake



DONE:
- Draw graphics for the maze
--- Walls
--- floor (code added but not used)
- Maze generation
--- 4x2 walls, randomly rotated in 90 degrees.
--- Random seed based on the "location" of the room in the maze.
 
- Draw graphics for the player.
--- 2 dir (right, left) with running animation
- Player movement
--- movement in 8 directions
- Player looses a life if touching a wall
- Player can switch rooms
- Entry door is blocked when entering a room
