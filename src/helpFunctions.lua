local QueueModule = require("Queue")
local random = math.random
---------------------------------------------------------------------------
-- - - - - - - - - - - - - Global Help Functions - - - - - - - - - - - - -- 
---------------------------------------------------------------------------

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function getAdjacentPos(row, col)
  -- returns table containing all adjacent positions [1]:row [2]:col to given position
  -- INCLUDING SELF. to change this:
  -- add if (not (dx == 0 and dy == 0)) then ... end
  
  local result = {}
  for dx =-1,1 do
    for dy=-1,1 do 
      result[#result+1] = { row+dy, col+dx }
    end  
  end
  for i=1,#result do
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function getRandNeighbour(row, col)
  local dir={ random(-1,1), random(-1,1) }
  return row+dir[1], col+dir[2]
end

function prims(unvisited)
  len = #unvisited
  local root=table.remove(unvisited, 1)
  local visited={}
  table.insert(visited, root)
  repeat
    local dist = 1e309    -- ~inf
    for i=1,#visited do
      for j=1,#unvisited do
        if (unvisited[j]:distanceTo(visited[i]) < dist) then
          dist = unvisited[j]:distanceTo(visited[i])
          v0 = visited[i]
          endIndex=j
        end
      end
    end
    v1 = table.remove(unvisited, endIndex)
    v0:addNeighbour(v1)
    table.insert(visited, v1)
until #visited == len

return visited[1], visited[#visited]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- source: https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- source: http://lua-users.org/wiki/CopyTable
function table.clone(org)
  return {table.unpack(org)}
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function getDist(start, goal)
  return math.sqrt(
    math.pow(math.abs(goal[1]-start[1]),2)+
    math.pow(math.abs(goal[2]-start[2]),2)
    )
end  

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- source: http://lua-users.org/wiki/StringIndexing
local strdefi=getmetatable('').__index
getmetatable('').__index=function(str,i) if type(i) == "number" then
    return string.sub(str,i,i)
    else return strdefi[i] end end