const std = @import("std");

const HEIGHT: comptime_int = 16;
const WIDTH: comptime_int = 64;
pub const ObjectTypes = enum { PLAYER, PLAYER_BULLET, ENEMY_BULLET, ENEMY1, ENEMY2 };

pub const Render = struct {
    tick: u64,
    timer: u64,
    display: [HEIGHT][WIDTH]u8,

    pub fn init() Render {
        var display: [HEIGHT][WIDTH]u8 = undefined;
        for (0..HEIGHT) |y| {
            for (0..WIDTH) |x| {
                display[y][x] = '_';
            }
        }
        std.debug.print("Game started!", .{});
        return Render{ .tick = 0, .timer = 0, .display = display };
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
        std.debug.print("Tick(s): {d}\n", .{self.tick});
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
        std.debug.print("Delay(s): {d}ms, timer: {d}ms\n", .{ time, self.timer });
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

pub const Object = struct {
    obj_type: ObjectTypes,
    x_pos: u64,
    y_pos: u64,
    texture: u8,

    pub fn init(obj_type: ObjectTypes, x_pos: u64, y_pos: u64, texture: u8) Object {
        std.debug.assert(x_pos >= 0 and x_pos <= WIDTH);
        std.debug.assert(y_pos >= 0 and y_pos <= HEIGHT);
        return Object{ .obj_type = obj_type, .x_pos = x_pos, .y_pos = y_pos, .texture = texture };
    }

    pub fn moveRight(self: *Object) error{OutOfDisplay}!void {
        if (self.x_pos + 1 >= WIDTH) {
            return error.OutOfDisplay;
        }
        self.x_pos += 1;
    }

    pub fn moveLeft(self: *Object) error{OutOfDisplay}!void {
        if (self.x_pos <= 0) {
            return error.OutOfDisplay;
        }
        self.x_pos -= 1;
    }

    pub fn moveUp(self: *Object) error{OutOfDisplay}!void {
        if (self.y_pos <= 0) {
            return error.OutOfDisplay;
        }
        self.y_pos -= 1;
    }

    pub fn moveDown(self: *Object) error{OutOfDisplay}!void {
        if (self.y_pos + 1 >= HEIGHT) {
            return error.OutOfDisplay;
        }
        self.y_pos += 1;
    }

    pub fn clone(self: *Object) Object {
        return Object{ .x_pos = self.x_pos, .y_pos = self.y_pos, .texture = self.texture };
    }
};
