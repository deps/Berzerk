A Berzerk Remake
By Deps and ippa

Written in ruby, using Gosu and Chingu

libgosu.org
github.com/ippa/chingu




TODO:
Ordered in intended execution order, but feel free to jump to a later one if desired.
Move completed ones to DONE below.

*** Period 1: Oct 7 to Oct 14
Over, one item left and moves to period 2
 

*** Period 2: Oct 14 to Oct 21   
- Draw graphics for the maze
--- floor (code added but not used)
- Droids moves faster when score increases.
- Game play background music. Ambient sounds, mostly. Something like that.
- Refactor!
 

*** Period 3: Oct 21 to Oct 28 
- High score list added and name entry
--- Only use name entry if score was high enough to be on the list
- Refactor!
 

*** Period 4: Oct 28 to Oct 31 
- Main menu
--- "Coin detected in pocket" played at random intervals
- Highscore menu
- Credits menu
- Settings menu
- Backgrounds music for the menus.

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

- Player can shoot
--- Press the fire button and direction
--- Player cannot move while shooting
--- Bullets are removed if touching a wall or is outside the room

- Scrolling messages

- Talking droid sounds added
--- Words:
    coins, detected, in, pocket, intruder, alert, the, humanoid, must, not, escape, chicken, fight, like, a,
    robot, got, charge, attack, kill, destroy. get. it
--- Messages:
	"The humanoid must not escape": Heard when the player escapes a room after destroying every robot.
	"Chicken, fight like a robot": Heard when the player escapes a room without destroying every robot.
	"Got the Humanoid, got the intruder": Heard when the player loses a life. 
	"Intruder alert! Intruder alert!": Spoken when Evil Otto appears.
    
--- Random:
	"Charge", "Attack", "Kill", "Destroy", or "Get" 
	followed by "The Humanoid", "The intruder", "it", or "the chicken" 
	(the last only if the player got the "Chicken, fight like a robot" message from 
	the previous room), creating sentences such as "Attack it", "Get the Humanoid", "Destroy the intruder", 
	"Kill the chicken", and so on. The speed and pitch of the phrases vary, from deep and slow, to high and fast.
--- When a message is created, play the words, but display it too using the show_message method.

- Draw droids
--- 4 direction animation, 4 frame idle animation with scanning eye
- Droids added to the room
--- Randomly placed, using the same seed as the walls of the maze
- Droids can move
- Droid can bump into walls, or each other, and explode
- Droid - player collisions
- Bullets kills player and droids
- Player death added

- Draw Evil Otto
--- needs only one frame. Might add another for the bounce
- Evil Otto appears after a time limit
--- Spawns where player started in the room
- Evil Otto moves towards the player
- Bullets are removed if touching Evil Otto
- Evil Otto destroys droids and player if he touches them

- Scores added
- Change droid color and firing ability based on score:
	score			droid color		shots (number allowed in total, from all droids in room)
	0-260			Yellow			No bullets
	260-1,200		Red				1
	1,200-3,000		Light Blue		2
	3,000-4,500		Light Green		3
	4,500-6,000		Purple			4
	6,000-8,000		Yellow			5
	8,000-10,000	White			1 fast shot (2x speed)
	10,000-12,000+	Light Blue		Two fast shots

- Droids are frozen for a while when the room is created.
- Bullets can collide with each other





--- ideas for achievements ---
- Killed <X> droids (10, 50, 100, 200, 500, 1000?)
- Visited <X> rooms (10, 50, 100?)
- Never been called a chicken
- <X>% accuracy (50, 75 and 100?)
- Mr Bomb Man (never shot a droid twice just to make it go boom)
- Kamikaze (lost all lives to running into droids)
- I pee on electric fences (lost all lives by running into walls)
- Hug the smiley (lost all lives by running into Evil Otto)
- 

