package game

import rl "vendor:raylib"

AnimationStates :: enum{
    IdleP,
    WalkP,
}

Animation :: struct{
    texture : rl.Texture2D,
    frames : int,
    scale : f32,
    width : f32,
    height : f32,
    cur_anim_frame : int,
    anim_timer : f32,
}

draw_animation :: proc(a : Animation, pos : rl.Vector2, flip : bool){
    frame_rec := rl.Rectangle{
        x = f32(a.cur_anim_frame) * a.width / f32(a.frames),
        y = 0,
        width = a.width / f32(a.frames),
        height = a.height
    }

    if flip{
        frame_rec.width = -frame_rec.width
    }

    player_dest := rl.Rectangle{
        x = pos.x,
        y = pos.y,
        width = a.width * a.scale / f32(a.frames),
        height = a.height * a.scale
    }
    rl.DrawTexturePro(a.texture, frame_rec, player_dest, {a.width / f32(a.frames) / 2, a.height / 2}, 0, rl.WHITE)
}

update_animation :: proc(a : ^Animation){
    a.anim_timer += rl.GetFrameTime()
    if a.anim_timer >= ANIM_FRAME_TIME{
        a.anim_timer = 0
        a.cur_anim_frame = (a.cur_anim_frame + 1) %% a.frames
    }
}

anim_reset :: proc(a : ^Animation){
    a.anim_timer = 0
    a.cur_anim_frame = 0
}

switch_animation :: proc(e : ^Entity, state : AnimationStates){
    e.cur_anim_state = state
    anim_reset(&e.anims[e.cur_anim_state])
}
