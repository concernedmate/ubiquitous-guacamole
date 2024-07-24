const std = @import("std");
const Game = @import("game.zig");
const Control = @import("control.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var GameObjects = std.ArrayList(Game.Object).init(allocator);
    var GarbageCollector = std.ArrayList(u64).init(allocator);
    defer GameObjects.deinit();
    defer GarbageCollector.deinit();

    var Renderer = Game.Render.init();
    const Player = Game.Object.init(Game.ObjectTypes.PLAYER, 1, 8, '>');
    GameObjects.append(Player) catch {};
    var delay = Renderer.process(0);

    var lastBulletTick: u64 = 0;
    var lastTick: u64 = 0;
    // const stdin = std.io.getStdIn();
    while (true) {
        Renderer.addTick();

        // var buffer: [1]u8 = Control.fileBasedControlsKEKW() catch {};
        // var buffered_reader = std.io.bufferedReader(stdin.reader());
        // _ = buffered_reader.read(&buffer) catch {};

        if (@rem(Renderer.tick, 5) == 0 and Renderer.tick != lastTick) {
            const PlayerBullet = Game.Object.init(Game.ObjectTypes.PLAYER_BULLET, GameObjects.items[0].x_pos + 1, GameObjects.items[0].y_pos, '=');
            GameObjects.append(PlayerBullet) catch {};
            lastBulletTick = Renderer.tick;
        }
        if (@rem(Renderer.tick, 10) == 0 and Renderer.tick != lastTick) {
            const input: u8 = Control.fileBasedControlsKEKW() catch 'o';
            switch (input) {
                @as(u8, 'w') => {
                    GameObjects.items[0].moveUp() catch {};
                },
                @as(u8, 's') => {
                    GameObjects.items[0].moveDown() catch {};
                },
                @as(u8, 'd') => {
                    GameObjects.items[0].moveRight() catch {};
                },
                @as(u8, 'a') => {
                    GameObjects.items[0].moveLeft() catch {};
                },
                else => {
                    std.debug.print("Pressed {c}", .{input});
                },
            }
        }
        for (GameObjects.items, 0..) |item, idx| {
            if (Renderer.tick != lastTick) {
                if (item.obj_type == Game.ObjectTypes.PLAYER_BULLET) {
                    GameObjects.items[idx].moveRight() catch {
                        GarbageCollector.append(idx) catch {};
                    };
                }
            }
        }
        var idx = GarbageCollector.items.len;
        while (idx > 0) {
            _ = GameObjects.orderedRemove(GarbageCollector.items[idx - 1]);
            _ = GarbageCollector.orderedRemove(idx - 1);
            idx -= 1;
        }
        for (GameObjects.items) |item| {
            Renderer.renderObject(item);
        }
        delay = Renderer.process(delay);
        lastTick = Renderer.tick;
    }
}
