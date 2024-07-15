const std = @import("std");

pub fn FizzBuzz(num: i64) void {
    if (@rem(num, 2) == 0) {
        std.debug.print("Fizz", .{});
    } else if (@rem(num, 3) == 0) {
        std.debug.print("Buzz", .{});
    } else if (@rem(num, 5) == 0) {
        std.debug.print("Fazz", .{});
    } else {
        std.debug.print("Bezz", .{});
    }
    std.debug.print(" <-- {d} \n", .{num});
}
