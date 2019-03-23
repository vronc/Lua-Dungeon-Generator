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

function main()
  height=60
  width=60
  nrOfLevels=5

  dungeon = Dungeon:new(nrOfLevels, height, width)
  initPlayer(dungeon[1])
  initBoss(dungeon[#dungeon])

  dungeon:printDungeon()
end

main()

