package game

import rl "vendor:raylib"

OBJ_CAP :: 100

ObjectNames :: enum{
    Tree
}

Object :: struct{
    pos : rl.Vector2,
    width : f32,
    height : f32,
    scale : f32,
    texture : rl.Texture2D,
    collider : Collider,
}

draw_object :: proc(o : Object){
    object_source := rl.Rectangle{
        x = 0,
        y = 0,
        width = o.width,
        height = o.height,
    }

    object_dest := rl.Rectangle{
        x = o.pos.x,
        y = o.pos.y,
        width = o.width * o.scale,
        height = o.height * o.scale,
    }
    rl.DrawTexturePro(o.texture, object_source, object_dest, 0, 0, rl.WHITE)
}

tree_init :: proc(pos : rl.Vector2, texture : rl.Texture2D) -> Object{
    tree_colider := Collider{
        x = 16,
        y = 60,
        width = 32,
        height = 4,
        color = rl.Color{0, 255, 0, 100}
    }
    tree := Object{
        pos = pos,
        width = 32,
        height = 32,
        scale = 2,
        texture = texture,
        collider = tree_colider,
    }
    return tree
}

exists :: proc(obj : Object) -> bool{
    return obj.width + obj.height != 0
}

is_infront :: proc(e : Entity, obj : Object) -> bool{
    return e.pos.y + e.anims[e.cur_anim_state].height / 2 < obj.pos.y + obj.height * obj.scale
    /*obj_rec := rl.Rectangle{
        x = obj.pos.x,
        y = obj.pos.y,
        width = obj.width * obj.scale,
        height = obj.height * obj.scale,
    }
    if rl.CheckCollisionRecs(get_collider_entity(e), obj_rec){
        collision := rl.GetCollisionRec(get_collider_entity(e), obj_rec)
        if collision.height == e.collider.height{
            return true
        }
    }
    return false*/
}

