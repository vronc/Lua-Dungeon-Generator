local FuncModule = require("helpFunctions")
local TileModule = require("Tile")
local RoomModule = require("Room")

local random = math.random
local floor = math.floor
local ceil = math.ceil
local min = math.min
local insert = table.insert

seed = os.time()
math.randomseed(seed)
print("seed: "..seed)

---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Level object - - - - - - - - - - - - - - - 
---------------------------------------------------------------------------

-- A Level object consist of several Tile objects which together make up 
-- one dungeon level.

Level = {height, width, matrix, rooms, entrances, staircases}
Level.__index = Level

Level.MIN_ROOM_SIZE = 3

Level.veinSpawnRate = 0.02
Level.soilSpawnRate = 0.05

function Level:new(height, width)
  if height < 10 or width < 10 then error("Level must have height>=10, width>=10") end
  
  local level = { 
    height=height,
    width=width,
    matrix={},
    rooms = {},
    entrances = {},
    staircases = {},
    rootRoom=nil,
    endRoom=nil
  }
  level.maxRoomSize = ceil(min(height, width)/10)+5
  level.maxRooms = ceil(min(height, width)/Level.MIN_ROOM_SIZE)
  -- Determines amount of random tiles built when generating corridors:
  level.scatteringFactor = ceil(math.max(height,width)/level.maxRoomSize)
  
  setmetatable(level, Level)
  return level
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:generateLevel()
  -- A default generation of a level. The function calls can be combined in 
  -- different ways for different outcomes.
  
  self:initMap(self.height, self.width)
  self:generateRooms()
  root=self:getRoomTree()
  self:buildCorridors(root)
  -- self:addCycles()
  self:addStaircases()
  self:addDoors()
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:initMap(height, width)

  -- Create void
  for i=-1,height+1 do
    self.matrix[i] = {}
    for j=0,width+1 do
      self.matrix[i][j] = Tile:new(Tile.EMPTY)
    end
  end

  self:addWalls(0, 0, height+1, width+1)
end 

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:printLevel ()

    for i=0,self.height+1 do
      local row="  "
      for j=0,self.width+1 do
        row=row..self.matrix[i][j].class..Tile.EMPTY
        --row=row..self.matrix[i][j].roomId..Tile.EMPTY    -- for exposing room-ids
      end
      print(row)
    end
  end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getRandRoom()
  -- return: Random room in level
  local i = random(1,#self.rooms)
  return self.rooms[i]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getRoot()
  -- return: Room that is root of room tree if such has been generated.
  return self.rootRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getEnd()
  -- return: Leaf room added last to tree if such has been generated.
  return self.endRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getStaircases()
  -- To retrieve individual staircase, index [1] for row, [2] for col on individual entry.
  return self.staircases
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:isRoom(row,col)
  return (self:getTile(row,col).roomId ~= 0)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:setMaxRooms(m)
  self.maxRooms=m
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:setScatteringFactor(f)
  self.scatteringFactor=f
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:setMaxRoomSize(m)
  self.maxRoomSize=m
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getAdjacentTiles(row, col)
  -- returns table containing all adjacent tiles to given position.
  -- Including self!
  
  local result={}
  local adj=getAdjacentPos(row,col)
  for i=1,#adj do
    local row, col = adj[i][1], adj[i][2]
    insert(result, self:getTile(row, col))
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
  function Level:generateRooms()
    for i = 1,self.maxRooms do
      self:generateRoom()
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping).
  
  local startRow = random(1, self.height-self.maxRoomSize)
  local startCol = random(1, self.width-self.maxRoomSize)
  
  local height = random(Level.MIN_ROOM_SIZE, self.maxRoomSize)
  local width = random(Level.MIN_ROOM_SIZE, self.maxRoomSize)

  for i=startRow-1, startRow+height+1 do
    for j=startCol-1, startCol+width+1 do
      
      if (self:isRoom(i,j)) then
        return            -- Room is overlapping other room->room is discarded
      end
    end
  end
  self:buildRoom(startRow, startCol, startRow+height, startCol+width)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:getRoomTree()
  if #self.rooms < 1 then error("Can't generate room tree, no rooms exists") end

  local root, lastLeaf = prims(table.clone(self.rooms))
  self.rootRoom = root
  self.endRoom = lastLeaf

  return root
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildRoom(startR, startC, endR, endC)
  -- init room object and paint room onto tiles.

  local id = #self.rooms+1
  local room = Room:new(id)
  local r,c =endR-floor((endR-startR)/2), endC-floor((endC-startC)/2)
  room:setCenter(r,c)
  insert(self.rooms, room)
  
  for i=startR, endR do
    for j=startC, endC do
      local tile = self:getTile(i,j)
      tile.roomId, tile.class = id, Tile.FLOOR
    end
  end
  self:addWalls(startR-1, startC-1, endR+1, endC+1)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildCorridors(root)
  -- Recursive DFS function for building corridors to every neighbour of a room (root)
  
  for i=1,#root.neighbours do
    local neigh = root.neighbours[i]
    self:buildCorridor(root, neigh)
    self:buildCorridors(neigh)
  end 
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildCorridor(from, to)
  -- Parameters from and to are both Room-objects.
  
  local start, goal = from.center, to.center
local nextTile = findNext(start, goal)
  repeat
    local row, col = nextTile[1], nextTile[2]
    self:buildTile(row, col)
    
    if random() < 0.5 then self:buildRandomTiles(row,col) end  -- Makes the corridors a little more interesting 
    nextTile = findNext(nextTile, goal)
  until (self:getTile(nextTile[1], nextTile[2]).roomId == to.id)
  
  if self:isValidEntrance(row, col) then 
    insert(self.entrances, self:getTile(row,col))
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildTile(r, c)
  -- Builds floor tile surrounded by walls. 
  -- Only floor and empty tiles around floor tiles turns to walls.

  local adj = getAdjacentPos(r,c)
  self:getTile(r, c).class = Tile.FLOOR
  for i=1,#adj do
    r, c = adj[i][1], adj[i][2]
    if not (self:getTile(r,c).class == Tile.FLOOR) then 
      self:placeWall(r,c)
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addDoors()
  -- Adds open or closed door randomly to entrance tiles.
  
  for i=1,#self.entrances do
    if random() > 0.5 then
      self.entrances[i].class = Tile.C_DOOR
    else
      self.entrances[i].class = Tile.O_DOOR
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:addStaircases()
  -- Adds both descending and ascending staircases to random rooms.
  -- Number of staircases depend on number of rooms.

  local maxStaircases = ceil(#self.rooms-(#self.rooms/2))+1
  local staircases = random(2,maxStaircases)

  repeat
    local room = self:getRandRoom()
    if not room.hasStaircase then
      self:placeStaircase(room, staircases)
      staircases = staircases-1
    end 
  until staircases==0
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addWalls(startR, startC, endR, endC)
  -- Places walls on circumference of given rectangle.
  
  -- Upper and lower sides
  for j=startC,endC do
    self:placeWall(startR, j)
    self:placeWall(endR, j)
  end
  
  -- Left and right sides
  for i=startR,endR do
    self:placeWall(i, startC)
    self:placeWall(i, endC)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeWall(r,c)
  -- Places wall at given coordinate. Could either place
  -- regular wall, soil or mineral vein
  
  local tile = self:getTile(r,c)
  
  if random() <= Level.veinSpawnRate then
    tile.class = Tile.VEIN
  elseif random() <= Level.soilSpawnRate then
    tile.class = Tile.SOIL
    Level.soilSpawnRate = 0.6     -- for clustering
  else
    tile.class = Tile.WALL
    Level.soilSpawnRate = 0.05
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeStaircase(room, staircases)
  -- Places staircase in given room. 
  -- Position is random number of steps away from center.
  
  local steps = random(0, floor(self.maxRoomSize/2))
  
  local nrow, ncol = room.center[1], room.center[2]
  repeat 
    row, col = nrow, ncol
    repeat
      nrow, ncol = getRandNeighbour(row, col)
    until self:getTile(nrow, ncol).class == Tile.FLOOR
    steps=steps-1
  until (self:getTile(nrow, ncol).roomId ~= room.id or steps <= 0)

  if staircases%2 == 0 then 
    self:getTile(row, col).class=Tile.D_STAIRCASE 
  else
    self:getTile(row, col).class=Tile.A_STAIRCASE 
  end
  room.hasStaircase = true
  insert( self.staircases, { row, col } )
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:isValidEntrance(row, col)
  -- Tile is a valid entrance position if there is a wall above and below it or
  -- to the left and to the right of it.
  
  return (
    (self:getTile(row+1,col):isWall() and self:getTile(row-1,col):isWall()) or
    (self:getTile(row,col+1):isWall() and self:getTile(row,col-1):isWall())
    )
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildRandomTiles(r,c)
  -- Creates random floor tiles around given tile. 
  
  local rand = random(1,self.scatteringFactor)
  for i=1,rand do
    local nr,nc = getRandNeighbour(r,c, true)
    
    if (self:getTile(nr,nc).roomId==0 and 
        withinBounds(nr,nc, self.height, self.width)) then
      self:buildTile(nr, nc)
      r,c=nr,nc
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addCycles()
  for _=1,5 do
    from = self:getRandRoom()
    to = self:getRandRoom()
    self:buildCorridor(from, to)
  end
end