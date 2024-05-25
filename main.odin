package game

import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:fmt"

WIDTH :: 1280
HEIGHT :: 720
PIXEL_HEIGHT :: 230
ANIM_FRAME_TIME :: 0.1
BACKGROUND_COLOR :: rl.Color{202, 223, 161, 255}

Entity :: struct{
    pos : rl.Vector2,
    speed : f32,
    anims : map[AnimationStates]Animation,
    cur_anim_state : AnimationStates,
    flip_sprite : bool,
    collider : Collider,
}

movement_handler :: proc(p : ^Entity, time : f32) -> [4]bool{  
    movement_ques := [4]bool{
                        rl.IsKeyDown(.W),
        rl.IsKeyDown(.A), rl.IsKeyDown(.S), rl.IsKeyDown(.D)
    }
    movement_dirs : int = 0  
    for que in movement_ques{
        movement_dirs += int(que)
    }
    speed : f32 = (movement_dirs > 1)? p.speed / math.sqrt_f32(2) : p.speed

    if p.cur_anim_state == .WalkP && movement_dirs == 0 || p.cur_anim_state == .IdleP && movement_dirs > 0{
        new_state : AnimationStates
        if movement_dirs > 0{
            new_state = .WalkP
        }
        else{
            new_state = .IdleP
        }
        switch_animation(p, new_state)
        //a := p.anims[p.cur_anim_state]
        update_collider_entity(p, {p.collider.x, p.collider.y}, p.collider.width, p.collider.height) //{-a.width / f32(a.frames) / 3, -a.height / 2}, a.width / f32(a.frames) / 3, a.height
    }

    if movement_ques[0]{
        p.pos.y -= speed * time
    }
    if movement_ques[1]{
        p.pos.x -= speed * time
        p.flip_sprite = true
    }
    if movement_ques[2]{
        p.pos.y += speed * time
    }
    if movement_ques[3]{
        p.pos.x += speed * time
        p.flip_sprite = false
    }
    return movement_ques
}

update_camera :: proc(camera : ^rl.Camera2D, p : Entity){
    camera^ = rl.Camera2D{
        zoom = f32(rl.GetScreenHeight())/PIXEL_HEIGHT,
        offset = {f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight()) / 2},
        target = p.pos
    }
}

player_init :: proc() -> Entity{
    p_idle_anim := Animation{
        texture = rl.LoadTexture("anims/Jenny/Jenny_idle.png"),
        frames = 1,
        scale = 1,
        width = 32,
        height = 32,
    }
    p_walk_anim := Animation{
        texture = rl.LoadTexture("anims/Jenny/Jenny_walk.png"),
        frames = 4,
        scale = 1,
        width = 128,
        height = 32,
    }
    p_anims := map[AnimationStates]Animation{
        .IdleP = p_idle_anim,
        .WalkP = p_walk_anim,
    }
    p_collider := Collider{
        x = -p_idle_anim.width / f32(p_idle_anim.frames) / 3,
        y = p_idle_anim.height / 6,
        width = p_idle_anim.width / f32(p_idle_anim.frames) / 3 * 2,
        height = p_idle_anim.height / 3,
        color = rl.Color{0, 255, 0, 100}
    }
    p := Entity{
        pos = {0, 0},
        speed = 100,
        anims = p_anims,
        cur_anim_state = .IdleP,
        collider = p_collider,
    }
    return p
}

hard_collision_processor_object :: proc(m_q : [4]bool, e : ^Entity, obj : Object, time : f32){
    if rl.CheckCollisionRecs(get_collider_entity(e^), get_collider_object(obj)){
        using e
        if m_q[0]{
            pos.y += speed * time
        }
        if m_q[1]{
            pos.x += speed * time
        }
        if m_q[2]{
            pos.y -= speed * time
        }
        if m_q[3]{
            pos.x -= speed * time
        }
    }
}

place_obj_rnd :: proc(obj_name : ObjectNames, tile : Tile, width, height : f32, texture : rl.Texture2D) -> Object{
    r : rand.Rand
    rand.init(&r, u64(tile.world_pos.x) * u64(tile.world_pos.y))
    rand.init(&r, rand.uint64(&r))
    if rand.int31(&r) % 2 == 0 {
        obj : Object
        switch obj_name{
            case ObjectNames.Tree:
                obj = tree_init({0, 0}, texture)
        }
        x := rand.int31(&r) % i32(width - obj.width)
        y := rand.int31(&r) % i32(height - obj.height)
        obj.pos = rl.Vector2{tile.world_pos.x + f32(x), tile.world_pos.y + f32(y)}
        return obj
    }
    else{
        return Object{}
    }
}

move_world :: proc(p_pos : rl.Vector2, world : ^World, texture : rl.Texture2D, objects : ^([OBJ_CAP]Object), obj_len : ^u16){
    if p_pos.x - world.tiles[0][1].world_pos.x < world.width * 1.5{
        shift_world("left", world, texture)
        for y := 0; y < WORLD_HEIGHT; y += 1{
            obj := place_obj_rnd(ObjectNames.Tree, world.tiles[y][0], world.width, world.height, texture)
            if !exists(obj){
                continue
            }
            (objects^)[obj_len^] = obj
            obj_len^ += 1
        }
    }
    if world.tiles[0][4].world_pos.x - p_pos.x < world.width * 0.5{
        shift_world("right", world, texture)
        for y := 0; y < WORLD_HEIGHT; y += 1{
            obj := place_obj_rnd(ObjectNames.Tree, world.tiles[y][WORLD_LEN - 1], world.width, world.height, texture)
            if !exists(obj){
                continue
            }
            (objects^)[obj_len^] = obj
            obj_len^ += 1
        }
    }
    if p_pos.y - world.tiles[1][0].world_pos.y < world.height{
        shift_world("up", world, texture)
        for x := 0; x < WORLD_LEN; x += 1{
            obj := place_obj_rnd(ObjectNames.Tree, world.tiles[0][x], world.width, world.height, texture)
            if !exists(obj){
                continue
            }
            (objects^)[obj_len^] = obj
            obj_len^ += 1
        }
    }
    if world.tiles[3][0].world_pos.y - p_pos.y < 0{
        shift_world("down", world, texture)
        for x := 0; x < WORLD_LEN; x += 1{
            obj := place_obj_rnd(ObjectNames.Tree, world.tiles[WORLD_HEIGHT - 1][x], world.width, world.height, texture)
            if !exists(obj){
                continue
            }
            (objects^)[obj_len^] = obj
            obj_len^ += 1
        }
    }
}

objects_init :: proc(world : ^World, objects : ^[OBJ_CAP]Object, obj_len : ^u16, texture : rl.Texture2D){
    for y := 0; y < WORLD_HEIGHT; y += 1{
        for x := 0; x < WORLD_LEN; x += 1{
            obj := place_obj_rnd(ObjectNames.Tree, world.tiles[y][x], world.width, world.height, texture)
            if !exists(obj){
                continue
            }
            (objects^)[obj_len^] = obj
            obj_len^ += 1
        }
    }
}

main :: proc(){
    fmt.println("Main start\n")
    rl.InitWindow(WIDTH, HEIGHT, "OWG")
    rl.SetWindowPosition(200, 200)
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(500)
    Tree_Texture := rl.LoadTexture("imgs/Tree.png")
    Grass_Texture := rl.LoadTexture("imgs/Grass.png")

    p := player_init()

    camera : rl.Camera2D
    world := world_init(Grass_Texture)
    objects : [OBJ_CAP]Object
    obj_len : u16 = 0
    objects_init(&world, &objects, &obj_len, Tree_Texture)
    fmt.print(obj_len)

    fmt.println()
    for !rl.WindowShouldClose(){
        update_camera(&camera, p)
        time := rl.GetFrameTime()
        rl.BeginDrawing()
        rl.ClearBackground(BACKGROUND_COLOR)
        rl.BeginMode2D(camera)
        //-------------------
        //behind player
        draw_world(&world)
        for obj in objects{
            if exists(obj) && !is_infront(p, obj){
                draw_object(obj)
                draw_collider_object(obj)
            }
        }
        //-------------------
        draw_animation(p.anims[p.cur_anim_state], p.pos, p.flip_sprite)
        draw_collider_entity(p)
        //-------------------
        //infront of player
        for obj in objects{
            if exists(obj) && !is_infront(p, obj){
                draw_object(obj)
                draw_collider_object(obj)
            }
        }
        //-------------------
        rl.EndMode2D()
        rl.EndDrawing()
        m_q := movement_handler(&p, time)
        update_animation(&p.anims[p.cur_anim_state])
        for obj in objects{
            if exists(obj){
                hard_collision_processor_object(m_q, &p, obj, time)
            }
        }
        move_world(p.pos, &world, Grass_Texture, &objects, &obj_len)
    }

    rl.CloseWindow()
}