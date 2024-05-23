package game

import rl "vendor:raylib"

Collider :: struct{
    x : f32,
    y : f32,
    width : f32,
    height : f32,
    color : rl.Color,
}

get_collider_entity :: proc(e : Entity) -> rl.Rectangle{
    return rl.Rectangle{
        x = e.pos.x + e.collider.x,
        y = e.pos.y + e.collider.y,
        width = e.collider.width,
        height = e.collider.height,
    }
}

draw_collider_entity :: proc(e : Entity){
    rl.DrawRectangleRec(
        get_collider_entity(e),
        e.collider.color,
    )
}

update_collider_entity :: proc(e : ^Entity, offset : rl.Vector2, width : f32, height : f32){
    e.collider.x = offset.x
    e.collider.y = offset.y
    e.collider.width = width
    e.collider.height = height
}


get_collider_object :: proc(o : Object) -> rl.Rectangle{
    return rl.Rectangle{
        x = o.pos.x + o.collider.x,
        y = o.pos.y + o.collider.y,
        width = o.collider.width,
        height = o.collider.height,
    }
}

draw_collider_object :: proc(o : Object){
    rl.DrawRectangleRec(
        get_collider_object(o),
        o.collider.color,
    )
}

update_collider_object :: proc(o : ^Object, offset : rl.Vector2, width : f32, height : f32){
    o.collider.x = offset.x
    o.collider.y = offset.y
    o.collider.width = width
    o.collider.height = height
}