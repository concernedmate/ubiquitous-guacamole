const std = @import("std");
const fizzbuzz = @import("fun/fizzbuzz.zig");
const fibonacci = @import("fun/fibonacci.zig");
const pyramid = @import("fun/pyramid.zig");

pub fn main() void {
    std.debug.print("Hello world!\n", .{});

    var i: u128 = 0;
    var start: i64 = std.time.milliTimestamp();
    // while (i <= 40) {
    //     std.debug.print("{d} <-- {d}!\n", .{ fibonacci.fibonacci(i), i });
    //     i += 1;
    // }
    // std.debug.print("{d}ms passed\n", .{std.time.milliTimestamp() - start});

    i = 0;
    start = std.time.milliTimestamp();
    fibonacci.fastFibonacciLoop(100) catch {
        std.debug.print("Errored!", .{});
        return;
    };
    std.debug.print("{d}ms passed\n", .{std.time.milliTimestamp() - start});

    i = 0;
    while (i < 1000) {
        pyramid.pyramidNum(21);
        pyramid.pyramidNumReverse(21);
        std.time.sleep(16666); // 16ms/frame = 60fps
        std.debug.print("\x1B[2J\x1B[H", .{}); //clear console
        i += 1;
    }
}
