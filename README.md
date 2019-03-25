# Dungeon Generator

This is a procedural dungeon generator written in Lua 5.3.5 for roguelike games.

## Example Output (default settings)
<img src="https://github.com/vronc/DungeonGen/blob/master/Images/defaultEx.png" alt="drawing" width="500"/>

## Example Output (customized settings)
<img src="https://github.com/vronc/DungeonGen/blob/master/Images/customizedEx.png" alt="drawing" width="500"/>

## How to use

In the root folder there is a file [ExampleMain.lua](https://github.com/vronc/DungeonGen/blob/master/ExampleMain.lua) which 
includes two examples of how the generator can be used. 
- __main()__: Using the Dungeon class (which holds many levels) and default generation settings for levels.
- __mainCustomizedLevel()__: Generating one level with customized settings.

## Default algorithm for levels

- Creates matrix of given height/width
- Places non-overlapping rooms of random sizes across matrix.
- Creates minimal spanning tree of rooms using Prim's algorithm (to ensure whole dungeon is reachable). 
- Builds tile corridors between rooms by doing DFS through room tree.
- Adds staircases and doors randomly but with certain constraints.
