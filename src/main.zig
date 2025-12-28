const std = @import("std");
const heap = std.heap;
const fs = std.fs;
const io = std.io;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const file = try fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const buf = try file.readToEndAlloc(alloc, std.math.maxInt(usize));
    defer alloc.free(buf);

    std.debug.print("{s}", .{buf});
}
