const std = @import("std");
const pyramid = @import("fun/pyramid.zig");

pub fn main() void {
    while (true) {
        pyramid.pyramidNum(21);
        pyramid.pyramidNumReverse(21);
        std.time.sleep(16666); // 16ms/frame = 60fps
        std.debug.print("\x1B[2J\x1B[H", .{}); //clear console
    }
}
