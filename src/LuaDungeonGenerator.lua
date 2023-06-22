
--[[

The main module to require.

]]

local PATH = (...):gsub('%.[^%.]+$', '')


local LuaDungeonGenerator = {}

LuaDungeonGenerator.Level = require(PATH .. ".Level")
LuaDungeonGenerator.Dungeon = require(PATH .. ".Dungeon")
LuaDungeonGenerator.Room = require(PATH .. ".Room")
LuaDungeonGenerator.Tile = require(PATH .. ".Tile")

return LuaDungeonGenerator
