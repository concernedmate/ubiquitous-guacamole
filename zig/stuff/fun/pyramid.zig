const std = @import("std");

pub fn pyramidNum(num: u64) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var array = std.ArrayList(u8).init(allocator);
    defer array.deinit();
    for (0..num) |_| {
        array.append('_') catch {};
    }

    var i: u64 = 0;
    const middle: f64 = @as(f64, @floatFromInt(num)) / 2;
    var right: u64 = @as(u64, @intFromFloat(middle));
    var left: u64 = @as(u64, @intFromFloat(middle));
    if (@as(u64, @intFromFloat(@ceil(middle))) != @as(u64, @intFromFloat(@floor(middle)))) {
        right = right + 1;
        left = left - 1;
    }
    while (i < @as(u64, @intFromFloat(middle))) {
        for (array.items, 0..) |_, idx| {
            if (idx == right + i) {
                array.items[idx] = '\\';
            } else if (idx == left - i) {
                array.items[idx] = '/';
            } else if (idx > left - i and idx < right + i) {
                array.items[idx] = '*';
            } else {
                array.items[idx] = ' ';
            }
        }
        if (i == 0 and right != left) {
            array.replaceRangeAssumeCapacity(left + 1, 1, "^");
        }
        std.debug.print("{s}\n", .{array.items});
        i += 1;
    }
    return;
}

pub fn pyramidNumReverse(num: u64) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var array = std.ArrayList(u8).init(allocator);
    defer array.deinit();
    for (0..num) |_| {
        array.append('_') catch {};
    }

    var i: u64 = 0;
    const middle: f64 = @as(f64, @floatFromInt(num)) / 2;
    var right: u64 = @as(u64, @intFromFloat(middle));
    var left: u64 = @as(u64, @intFromFloat(middle));
    if (@as(u64, @intFromFloat(@ceil(middle))) != @as(u64, @intFromFloat(@floor(middle)))) {
        right = right + 1;
        left = left - 1;
    }
    while (i < @as(u64, @intFromFloat(middle))) {
        for (array.items, 0..) |_, idx| {
            if (idx == array.items.len - 1 - i) {
                array.items[idx] = '/';
            } else if (idx == 0 + i) {
                array.items[idx] = '\\';
            } else if (idx > (0 + i) and idx < (array.items.len - 1 - i)) {
                array.items[idx] = '*';
            } else {
                array.items[idx] = ' ';
            }
        }
        std.debug.print("{s}\n", .{array.items});
        i += 1;
    }
    return;
}
