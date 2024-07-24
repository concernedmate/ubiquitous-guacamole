const std = @import("std");

pub fn print_read() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();

    try stdout.writeAll("// Enter text: ");

    var buffer: [1]u8 = undefined;
    var buffered_reader = std.io.bufferedReader(stdin.reader());
    _ = try buffered_reader.read(&buffer);
    try stdout.writer().print("Your text is: {s}", .{buffer});
}
