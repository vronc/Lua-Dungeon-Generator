---------------------------------------------------------------------------
-- - - - - - - - - - - - - Global Help Functions - - - - - - - - - - - - -- 
---------------------------------------------------------------------------


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

function getDist(row1, col1, row2, col2)
  return math.sqrt(
    math.pow(math.abs(row1-row2),2)+
    math.pow(math.abs(col1-col2),2)
    )
end  

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- source: http://lua-users.org/wiki/StringIndexing
local strdefi=getmetatable('').__index
getmetatable('').__index=function(str,i) if type(i) == "number" then
    return string.sub(str,i,i)
    else return strdefi[i] end end