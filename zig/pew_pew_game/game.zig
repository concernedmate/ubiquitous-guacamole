const std = @import("std");

pub const HEIGHT: comptime_int = 16;
pub const WIDTH: comptime_int = 64;

pub const Render = struct {
    tick: u64,
    timer: u64,
    score: u256,
    display: [HEIGHT][WIDTH]u8,

    pub fn init() Render {
        var display: [HEIGHT][WIDTH]u8 = undefined;
        for (0..HEIGHT) |y| {
            for (0..WIDTH) |x| {
                display[y][x] = '_';
            }
        }
        std.debug.print("Game started!", .{});
        return Render{ .tick = 0, .timer = 0, .score = 0, .display = display };
    }

    fn clear(self: *Render) void {
        var display: [HEIGHT][WIDTH]u8 = undefined;
        for (0..HEIGHT) |y| {
            for (0..WIDTH) |x| {
                display[y][x] = '_';
            }
        }
        self.display = display;
    }

    pub fn process(self: *Render, deltaMS: u64) u64 {
        if (deltaMS < 4) {
            std.time.sleep((4 - deltaMS) * std.time.ns_per_ms);
            self.timer += (4 - deltaMS);
        }
        const start = std.time.milliTimestamp();
        var array: [WIDTH]u8 = undefined;
        std.debug.print("\x1B[2J\x1B[H", .{}); //clear console
        std.debug.print("Score: {d}\n", .{self.score});
        for (0..HEIGHT) |y| {
            for (0..WIDTH) |x| {
                if (self.display[y][x] != '_') {
                    array[x] = self.display[y][x];
                } else {
                    array[x] = '_';
                }
            }
            std.debug.print("{s}\n", .{array});
        }
        const time = @as(u64, @intCast(std.time.milliTimestamp() - start));
        std.debug.print("Delay(s): {d}ms, sleep: {d}ms, tick(s): {d}\n", .{ time, self.timer, self.tick });
        self.clear();
        return time;
    }

    pub fn addTick(self: *Render) void {
        if (self.timer >= std.time.ms_per_s * 0.02) {
            self.tick += 1;
            self.timer = 0;
        }
    }

    pub fn renderObject(self: *Render, obj: Object) void {
        self.display[obj.y_pos][obj.x_pos] = obj.texture;
    }
};

pub const ValidMoveset = enum { LEFT, RIGHT, UP, DOWN, UPLEFT, DOWNLEFT, UPRIGHT, DOWNRIGHT, NOTHING };

pub const ObjectTypes = enum { PLAYER, PLAYER_BULLET, ENEMY_BULLET, ENEMY };
pub const Object = struct {
    obj_type: ObjectTypes,
    x_pos: u64,
    y_pos: u64,
    health: u32,
    moveset: []const ValidMoveset,
    curr_move: u32,
    mark_to_delete: u32,
    texture: u8,

    pub fn init(obj_type: ObjectTypes, x_pos: u64, y_pos: u64, health: u32, moveset: []const ValidMoveset, texture: u8) Object {
        std.debug.assert(x_pos >= 0 and x_pos <= WIDTH);
        std.debug.assert(y_pos >= 0 and y_pos <= HEIGHT);
        return Object{
            .obj_type = obj_type,
            .x_pos = x_pos,
            .y_pos = y_pos,
            .health = health,
            .moveset = moveset,
            .curr_move = 0,
            .mark_to_delete = 0,
            .texture = texture,
        };
    }

    pub fn clone(self: *Object) Object {
        return Object{ .x_pos = self.x_pos, .y_pos = self.y_pos, .texture = self.texture };
    }

    // call every tick
    pub fn doMovement(self: *Object) void {
        if (self.texture == 'X') {
            self.mark_to_delete = 1;
            return;
        }
        if (self.health == 0) {
            self.texture = 'X';
            return;
        }

        var move_success: i32 = 0;
        if (self.moveset[self.curr_move] == ValidMoveset.UP) {
            move_success += moveUp(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.DOWN) {
            move_success += moveDown(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.RIGHT) {
            move_success += moveRight(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.LEFT) {
            move_success += moveLeft(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.UPLEFT) {
            move_success += moveUp(self);
            move_success += moveLeft(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.UPRIGHT) {
            move_success += moveUp(self);
            move_success += moveRight(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.DOWNLEFT) {
            move_success += moveDown(self);
            move_success += moveLeft(self);
        } else if (self.moveset[self.curr_move] == ValidMoveset.DOWNRIGHT) {
            move_success += moveDown(self);
            move_success += moveRight(self);
        }
        if (move_success != 0) {
            self.mark_to_delete = 1;
        }
        self.curr_move += 1;
        if (self.moveset.len == self.curr_move) {
            self.curr_move = 0;
        }
    }

    pub fn moveRight(self: *Object) i32 {
        if (self.x_pos + 1 >= WIDTH) {
            return -1;
        }
        self.x_pos += 1;
        return 0;
    }

    pub fn moveLeft(self: *Object) i32 {
        if (self.x_pos <= 0) {
            return -1;
        }
        self.x_pos -= 1;
        return 0;
    }

    pub fn moveUp(self: *Object) i32 {
        if (self.y_pos <= 0) {
            return -1;
        }
        self.y_pos -= 1;
        return 0;
    }

    pub fn moveDown(self: *Object) i32 {
        if (self.y_pos + 1 >= HEIGHT) {
            return -1;
        }
        self.y_pos += 1;
        return 0;
    }

    pub fn minusHealth(self: *Object, amount: u32) void {
        if (self.health >= amount) {
            self.health -= amount;
        }
    }
};

pub fn createPlayer(x_pos: u64, y_pos: u64) Object {
    const move = [1]ValidMoveset{ValidMoveset.NOTHING};
    return Object.init(ObjectTypes.PLAYER, x_pos, y_pos, 3, &move, '>');
}

pub fn createPlayerBullet(x_pos: u64, y_pos: u64) Object {
    const move = [1]ValidMoveset{ValidMoveset.RIGHT};
    return Object.init(ObjectTypes.PLAYER_BULLET, x_pos, y_pos, 1, &move, '=');
}

pub fn createEnemy1(x_pos: u64, y_pos: u64) Object {
    const move = [_]ValidMoveset{ ValidMoveset.UPLEFT, ValidMoveset.NOTHING, ValidMoveset.UPLEFT, ValidMoveset.NOTHING, ValidMoveset.UPLEFT, ValidMoveset.NOTHING, ValidMoveset.DOWNLEFT, ValidMoveset.NOTHING, ValidMoveset.DOWNLEFT, ValidMoveset.NOTHING, ValidMoveset.DOWNLEFT, ValidMoveset.NOTHING };
    return Object.init(ObjectTypes.ENEMY, x_pos, y_pos, 1, &move, '<');
}

pub fn createEnemy2(x_pos: u64, y_pos: u64) Object {
    const move = [_]ValidMoveset{ ValidMoveset.DOWNLEFT, ValidMoveset.NOTHING, ValidMoveset.NOTHING };
    return Object.init(ObjectTypes.ENEMY, x_pos, y_pos, 1, &move, '/');
}

pub fn createEnemy3(x_pos: u64, y_pos: u64) Object {
    const move = [_]ValidMoveset{ ValidMoveset.UPLEFT, ValidMoveset.NOTHING, ValidMoveset.NOTHING };
    return Object.init(ObjectTypes.ENEMY, x_pos, y_pos, 1, &move, '\\');
}
