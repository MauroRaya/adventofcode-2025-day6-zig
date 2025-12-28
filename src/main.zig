const std = @import("std");
const heap = std.heap;
const fs = std.fs;
const mem = std.mem;
const math = std.math;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const buf = try readFile(alloc, "test.txt");
    defer alloc.free(buf);

    std.debug.print("{s}", .{buf});
}

// https://ziggit.dev/t/how-to-read-an-entire-text-file-line-by-line-into-memory-efficiently/6433/4
pub fn readFile(alloc: mem.Allocator, path: []const u8) ![]u8 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();
    return file.readToEndAlloc(alloc, math.maxInt(usize));
}
