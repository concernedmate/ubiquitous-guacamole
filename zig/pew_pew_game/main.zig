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
    var delay = Renderer.process(0);

    const Player = Game.createPlayer(2, 8);
    GameObjects.append(Player) catch {};

    var lastBulletTick: u64 = 0;
    var lastTick: u64 = 0;

    var randGen = std.rand.DefaultPrng.init(0);
    while (true) {
        Renderer.addTick();

        // spawn bullet
        if (@rem(Renderer.tick, 5) == 0 and Renderer.tick != lastTick) {
            const PlayerBullet = Game.createPlayerBullet(GameObjects.items[0].x_pos + 1, GameObjects.items[0].y_pos);
            GameObjects.append(PlayerBullet) catch {};
            lastBulletTick = Renderer.tick;
        }

        // spawn enemy
        if (@rem(Renderer.tick, 15) == 0 and Renderer.tick != lastTick) {
            const Enemy1 = Game.createEnemy1(Game.WIDTH - 1, std.rand.uintAtMost(randGen.random(), u64, Game.HEIGHT));
            GameObjects.append(Enemy1) catch {};
        }

        // spawn enemy
        if (@rem(Renderer.tick, 10) == 0 and Renderer.tick != lastTick) {
            const Enemy2 = Game.createEnemy2(std.rand.uintLessThan(randGen.random(), u64, Game.WIDTH), 0);
            GameObjects.append(Enemy2) catch {};
            const Enemy3 = Game.createEnemy3(std.rand.uintLessThan(randGen.random(), u64, Game.WIDTH), Game.HEIGHT - 1);
            GameObjects.append(Enemy3) catch {};
        }

        // player movement
        if (@rem(Renderer.tick, 5) == 0 and Renderer.tick != lastTick) {
            const input: u8 = Control.fileBasedControlsKEKW() catch 'o';
            switch (input) {
                @as(u8, 'w') => {
                    _ = GameObjects.items[0].moveUp();
                },
                @as(u8, 's') => {
                    _ = GameObjects.items[0].moveDown();
                },
                @as(u8, 'd') => {
                    _ = GameObjects.items[0].moveRight();
                },
                @as(u8, 'a') => {
                    _ = GameObjects.items[0].moveLeft();
                },
                else => {
                    std.debug.print("Pressed {c}", .{input});
                },
            }
        }

        // object movement
        for (GameObjects.items, 0..) |item, idx| {
            if (Renderer.tick != lastTick and item.mark_to_delete == 0) {
                GameObjects.items[idx].doMovement();
                if (GameObjects.items[idx].mark_to_delete == 1) {
                    GarbageCollector.append(idx) catch {};
                }
            }
        }

        // object movement detection
        for (GameObjects.items, 0..) |item, idx| {
            for (GameObjects.items, 0..) |item2, idx2| {
                if (item.texture != 'X' and item.x_pos == item2.x_pos and item.y_pos == item2.y_pos and idx != idx2) {
                    GameObjects.items[idx].minusHealth(1);

                    if (GameObjects.items[idx].obj_type == Game.ObjectTypes.ENEMY and Renderer.tick != lastTick) {
                        Renderer.score += 1;
                    }
                    break;
                }
            }
        }

        // delete invalid objects
        var garbage_idx = GarbageCollector.items.len;
        while (garbage_idx > 0) {
            _ = GameObjects.orderedRemove(GarbageCollector.items[garbage_idx - 1]);
            _ = GarbageCollector.orderedRemove(garbage_idx - 1);
            garbage_idx -= 1;
        }

        for (GameObjects.items) |item| {
            Renderer.renderObject(item);
        }
        delay = Renderer.process(delay);
        lastTick = Renderer.tick;
    }
}
