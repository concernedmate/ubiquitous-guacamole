const std = @import("std");
const Game = @import("game.zig");

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
    while (true) {
        Renderer.addTick();
        if (@rem(Renderer.tick, 10) == 0 and Renderer.tick != lastBulletTick) {
            const PlayerBullet = Game.Object.init(Game.ObjectTypes.PLAYER_BULLET, 1, 8, '=');
            GameObjects.append(PlayerBullet) catch {};
            lastBulletTick = Renderer.tick;
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
