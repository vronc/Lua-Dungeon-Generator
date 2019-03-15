seed = os.time()
math.randomseed(seed)
print("seed: "..seed)

-----------------------------------------------------------
-- - - - - - - - - - - Tiles object - - - - - - - - - - - - 
-----------------------------------------------------------

-- A Tiles object keep an overview of the Tile objects which are kept in a matrix

Tiles = {height, width, matrix}
Tiles.__index = Tiles

function Tiles:new(height, width)
  local tiles = {}
  tiles.height = height
  tiles.width = width
  tiles.matrix ={}
  -- Will hold all rooms, index is ID 
  tiles.rooms = {}
  
  setmetatable(tiles, Tiles)

  -- Create upper and lower bound walls
  tiles.matrix[0] = {}
  wallTile = Tile:new("#")
  for j=0,width+1 do
    tiles.matrix[0][j] = wallTile
  end
  tiles.matrix[height+1] = {}
  for j=0,width+1 do
    tiles.matrix[height+1][j] = wallTile
  end
  
  for i=1,height do
    tiles.matrix[i] = {}     -- create a new row
    tiles.matrix[i][0] = wallTile
    for j=1,width do
      tiles.matrix[i][j] = Tile:new(" ")
    end
    tiles.matrix[i][width+1] = wallTile
  end
  return tiles
end

  -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:printTiles ()

    for i=0,self.height+1 do
      row=""
      for j=0,self.width+1 do
        row=row..self.matrix[i][j].class.." "
      end
      print(row)
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
  function Tiles:generateRooms(amount)
    for i = 1,amount do
      self:generateRoom()
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping)
  minRoomSize = 3
  maxRoomSize = 10 
  startRow = math.random(1, self.height-maxRoomSize)
  startCol = math.random(1, self.width-maxRoomSize)
  
  height = math.random(minRoomSize, maxRoomSize)
  width = math.random(minRoomSize, maxRoomSize)
  
  ok = true
  for i=startRow-1, startRow+height+1 do
    for j=startCol-1, startCol+width+1 do
      
      if not (self:getTile(i,j).roomId == 0) then
        ok = false
        break
      end
    end
  end
  
  if ok then
    self:buildRoom(startRow, startCol, startRow+height, startCol+width)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:buildRoom(startR, startC, endR, endC)
  -- paint room onto board
    id = #self.rooms+1
    table.insert(self.rooms, Room:new(id))
    for i=startR, endR do
      for j=startC, endC do
        self:getTile(i,j).roomId = id
        self:getTile(i,j).class = "."
      end
    end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
-----------------------------------------------------------
-- - - - - - - - - - - - Tile object - - - - - - - - - - -- 
-----------------------------------------------------------

-- Tile objects have a class (wall, entrance, floor, stairway...)
-- Unaware of placement in tiles matrix

Tile = {class, visited, boundingBox}
Tile.__index = Tile

function Tile:new(c)
  local tile = {}
  tile.class = c
  tile.roomId = 0
  return tile
end

-----------------------------------------------------------
-- - - - - - - - - - - - Room object - - - - - - - - - - -- 
-----------------------------------------------------------

Room = { id }
Tile.__index = Room

function Room:new(id)
  local room = {}
  room.id = id
  return room
end


-- View example
m = Tiles:new(40,40)
m:generateRooms(10)
m:printTiles()