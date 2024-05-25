package game

import rl "vendor:raylib"
import "core:fmt"

WORLD_LEN :: 6
WORLD_HEIGHT :: 5

Image :: struct{
    texture : rl.Texture2D,
    width : f32,
    height : f32,
}

Tile :: struct{
    pos : [2]int, //{x, y}
    world_pos : rl.Vector2,
    img : Image,
}

World :: struct{
    tiles : [WORLD_HEIGHT][WORLD_LEN]Tile,
    width : f32,
    height : f32,
}

tile_init :: proc(x, y : int, world_x, world_y : f32, texture : rl.Texture2D, source_w, source_h : f32) -> Tile{
    img := Image{
        texture = texture,
        width = source_w,
        height = source_h,
    }
    return Tile{
        pos = {x, y},
        world_pos = rl.Vector2{world_x, world_y},
        img = img,
    }
}

draw_tile :: proc(tile : Tile, width, height : f32){
    source_rec := rl.Rectangle{
        x = 0,
        y = 0,
        width = tile.img.width,
        height = tile.img.height,
    }

    dest_rec := rl.Rectangle{
        x = f32(tile.world_pos.x),
        y = f32(tile.world_pos.y),
        width = width,
        height = height,
    }
    //fmt.println(rl.Vector2{f32(tile.world_pos[0]) * tile.width, f32(tile.world_pos[1]) * tile.height})
    //rl.DrawCircleV(rl.Vector2{f32(tile.world_pos[0]) * tile.width, f32(tile.world_pos[1]) * tile.height}, 16, rl.RED)
    rl.DrawTexturePro(tile.img.texture, source_rec, dest_rec, 0, 0, rl.WHITE)
}

world_init :: proc(texture : rl.Texture2D) -> World{
    world : World
    screen_width := f32(rl.GetScreenWidth()) * PIXEL_HEIGHT / f32(rl.GetScreenHeight())
    screen_height := f32(PIXEL_HEIGHT)
    width := screen_width / 4
    height := screen_height / 3
    
    for y := 0; y < WORLD_HEIGHT; y += 1{
        for x := 0; x < WORLD_LEN; x += 1{
            world.tiles[y][x] = tile_init(
                x, y,
                f32(x) * width - screen_width / 2 - width,
                f32(y) * height - screen_height / 2 - height,
                texture, 32, 32
            )
        }
    }
    world.width = width
    world.height = height
    return world
}

draw_world :: proc(world : ^World){
    for y := 0; y < WORLD_HEIGHT; y += 1{
        for x := 0; x < WORLD_LEN; x += 1{
            draw_tile(world.tiles[y][x], world.width, world.height)
        }
    }
}

shift_world :: proc(dir : string, world : ^World, texture : rl.Texture2D){
    is_old := proc(x, y : int) -> bool {return false}
    old_tile := proc(x, y : int, world : ^World) -> Tile {return world.tiles[0][0]}
    new_tile_pos := proc(x, y : int, world : ^World) -> rl.Vector2 {return rl.Vector2{0, 0}}
    switch dir{
        case "up":
            is_old = proc(x, y : int) -> bool {return y > 0}
            old_tile = proc(x, y : int, world : ^World) -> Tile {return world.tiles[y - 1][x]}
            new_tile_pos = proc(x, y : int, world : ^World) -> rl.Vector2 {
                return rl.Vector2{
                    world.tiles[0][x].world_pos.x,
                    world.tiles[0][x].world_pos.y - world.height
                }
            }
        case "down":
            is_old = proc(x, y : int) -> bool {return y < 4}
            old_tile = proc(x, y : int, world : ^World) -> Tile {return world.tiles[y + 1][x]}
            new_tile_pos = proc(x, y : int, world : ^World) -> rl.Vector2 {
                return rl.Vector2{
                    world.tiles[0][x].world_pos.x,
                    world.tiles[WORLD_HEIGHT - 1][x].world_pos.y + world.height
                }
            }
        case "right":
            is_old = proc(x, y : int) -> bool {return x < 5}
            old_tile = proc(x, y : int, world : ^World) -> Tile {return world.tiles[y][x + 1]}
            new_tile_pos = proc(x, y : int, world : ^World) -> rl.Vector2 {
                return rl.Vector2{
                    world.tiles[y][WORLD_LEN - 1].world_pos.x + world.width,
                    world.tiles[y][0].world_pos.y
                }
            }
        case "left":
            is_old = proc(x, y : int) -> bool {return x > 0}
            old_tile = proc(x, y : int, world : ^World) -> Tile {return world.tiles[y][x - 1]}
            new_tile_pos = proc(x, y : int, world : ^World) -> rl.Vector2 {
                return rl.Vector2{
                    world.tiles[y][0].world_pos.x - world.width,
                    world.tiles[y][0].world_pos.y
                }
            }
    }
    for y := 0; y < WORLD_HEIGHT; y += 1{
        for x := 0; x < WORLD_LEN; x += 1{
            if is_old(x, y){
                world.tiles[y][x] = old_tile(x, y, world)
                world.tiles[y][x].pos = {x, y}
            }
            else{
                new_pos := new_tile_pos(x, y, world)
                //fmt.println(new_pos)
                world.tiles[y][x] = tile_init(
                    x, y,
                    new_pos.x, new_pos.y,
                    texture,
                    32, 32
                )
            }
        }
    }
    /*fmt.println()
    for y := 0; y < WORLD_HEIGHT; y += 1{
        for x := 0; x < WORLD_LEN; x += 1{
            fmt.println(world.tiles[y][x].pos, ": ", world.tiles[y][x].world_pos)
        }   
    }*/
}
