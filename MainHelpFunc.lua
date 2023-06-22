-----------------------------------------------------------------------------------
-- - - - - - - - - - - Help functions for main examples - - - - - - - - - - - - - -
-----------------------------------------------------------------------------------
local LuaDungeonGenerator = require("src.LuaDungeonGenerator")

local Helper = LuaDungeonGenerator.Helper
local Tile = LuaDungeonGenerator.Tile


function initPlayer(level)
  local c=level:getRoot().center
  local adj = Helper.getAdjacentPos(c[1], c[2])
  local i=1
  local endr, endc
  repeat
    endr, endc = adj[i][1], adj[i][2]
    i=i+1
  until level:getTile(endr,endc).class == Tile.FLOOR
  
  level:getTile(endr,endc).class = Tile.PLAYER
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function initBoss(level) 
  local c=level:getEnd().center
  local adj = Helper.getAdjacentPos(c[1], c[2])
  local i=1
  local endr, endc
  repeat
    endr, endc = adj[i][1], adj[i][2]
    i=i+1
  until level:getTile(endr,endc).class == Tile.FLOOR
  
  level:getTile(endr,endc).class = Tile.BOSS
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 