const std = @import("std");

pub fn fileBasedControlsKEKW() !u8 {
    const file = try std.fs.cwd().openFile("control_file.txt", .{});
    defer file.close();

    var buffer: [1]u8 = undefined;
    try file.seekTo(0);
    _ = try file.read(&buffer);
    return buffer[0];
}
