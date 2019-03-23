local LevelModule = require("Level")
---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - Dungeon object - - - - - - - - - - - - - - - 
---------------------------------------------------------------------------

-- Dungeon objects have several levels (consisting of Level objects) which
-- together represent a whole dungeon.

Dungeon = {levels, height, width}
Dungeon.__index = Dungeon

function Dungeon:new(nrOfLevels, height, width)
  local dungeon = {}
  dungeon.hight = height
  dungeon.width = width
  
  for i=1,nrOfLevels do
    newLevel = Level:new(height, width)
    newLevel:generateLevel()
    dungeon[i] = newLevel
  end
  
  setmetatable(dungeon, Dungeon)
  return dungeon
end

function Dungeon:printDungeon()
  for i=1,#dungeon do
      local s = "L E V E L  "..i
      local space=""
    for i=1, math.floor((self.width+2)/2-(string.len(s))/4) do
      space = space.."  "
    end
    print(space..s..space)
    print()
    dungeon[i]:printLevel()
    print()
  end
end