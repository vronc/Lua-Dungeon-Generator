local DungeonModule = require("Dungeon")


-----------------------------------------------------------------------------------
-- - - - - - - - - - - - - Help functions for main - - - - - - - - - - - - - - - -- 
-----------------------------------------------------------------------------------

function initPlayer(level)
  c=level:getRoot().center
  adj = getAdjacentPos(c[1], c[2])
  i=1
  repeat
    endr, endc = adj[i][1], adj[i][2]
    i=i+1
  until level:getTile(endr,endc).class == Tile.FLOOR
  
  level:getTile(endr,endc).class = Tile.PLAYER
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function initBoss(level) 
  c=level:getEnd().center
  adj = getAdjacentPos(c[1], c[2])
  i=1
  repeat
    endr, endc = adj[i][1], adj[i][2]
    i=i+1
  until level:getTile(endr,endc).class == Tile.FLOOR
  
  level:getTile(endr,endc).class = Tile.BOSS
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-----------------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Example of main - - - - - - - - - - - - - - - - --
-----------------------------------------------------------------------------------
function main()

  -- Settings for level sizes and number of levels in dungeon.
  height=30
  width=60
  nrOfLevels=1

  dungeon = Dungeon:new(nrOfLevels, height, width)
  
  -- generate with default settings
  dungeon:generateDungeon()
  
  -- generate with advanced settings, 
  -- params: (advanced, maxRooms, maxRoomSize, scatteringFactor)
  -- dungeon:generateDungeon(true, 30, 10, 30)
  
  -- inits a player in level 1, a boss in last level
  initPlayer(dungeon.levels[1])
  initBoss(dungeon.levels[#dungeon.levels])

  dungeon:printDungeon()
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

main()

