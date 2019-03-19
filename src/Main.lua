require "Tiles"
require "Tile"
require "Room"

seed = os.time()
--seed=1552952491
math.randomseed(seed)
print("seed: "..seed)

dungeon = Tiles:new(50,50,15)
dungeon:printTiles()