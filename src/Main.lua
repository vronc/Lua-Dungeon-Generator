require "Level"
require "Tile"
require "Room"

seed = os.time()
--seed=1552952491
math.randomseed(seed)
print("seed: "..seed)

lvl = Level:new(50,50,15)
lvl:printLevel()