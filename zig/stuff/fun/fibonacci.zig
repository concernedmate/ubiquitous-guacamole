const std = @import("std");

pub fn fibonacci(num: u128) u128 {
    if (num == 0 or num == 1) return 1;
    return fibonacci(num - 1) + fibonacci(num - 2);
}

pub fn fastFibonacciLoop(num: u128) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var map = std.AutoHashMap(u128, u128).init(allocator);
    defer map.deinit();

    var i: u128 = 0;
    while (i <= num) {
        var result: u128 = 0;
        if (i > 2 and map.contains(i - 1) and map.contains(i - 2)) {
            result = (map.get(i - 1) orelse 0) + (map.get(i - 2) orelse 0);
            try map.put(i, result);
        } else {
            result = 1;
            try map.put(i, result);
        }
        std.debug.print("{d} <-- {d}!\n", .{ result, i });
        i += 1;
    }
}
