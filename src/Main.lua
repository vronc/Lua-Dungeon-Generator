require "Dungeon"

seed = os.time()
--seed=1552952491
math.randomseed(seed)
print("seed: "..seed)

dungeon = Dungeon:new(10,50,50)
dungeon:printDungeon()