local DungeonModule = require("Dungeon")

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

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

function main()
  height=40
  width=60
  nrOfLevels=5

  dungeon = Dungeon:new(nrOfLevels, height, width)
  dungeon:generateDungeon()
  --params: (advanced, maxRooms, maxRoomSize, scatteringFactor)
  --dungeon:generateDungeon(true, 15, 20, 20)
  
  initPlayer(dungeon.levels[1])
  initBoss(dungeon.levels[#dungeon.levels])

  dungeon:printDungeon()
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

main()

