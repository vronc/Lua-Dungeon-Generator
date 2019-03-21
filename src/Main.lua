local DungeonModule = require("Dungeon")

local nrOfLevels = 5
local height = 60
local width = 60
dungeon = Dungeon:new(nrOfLevels, height, width)
dungeon:printDungeon()