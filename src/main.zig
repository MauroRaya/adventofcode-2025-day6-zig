const std = @import("std");
const heap = std.heap;
const fs = std.fs;
const ArrayList = std.ArrayList;
const mem = std.mem;
const math = std.math;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const buf = try readFile(alloc, "test.txt");
    defer alloc.free(buf);

    var iterators = try ArrayList(mem.SplitIterator(u8, mem.DelimiterType.any)).initCapacity(alloc, 1024);
    defer iterators.deinit(alloc);

    var lines = mem.splitAny(u8, buf, "\n");

    while (lines.next()) |line| {
        try iterators.append(alloc, mem.splitAny(u8, line, " "));
    }

    for (iterators.items) |*iterator| {
        while (iterator.next()) |char| {
            std.debug.print("{s} ", .{char});
        }
        std.debug.print("\n", .{});
    }
}

// https://ziggit.dev/t/how-to-read-an-entire-text-file-line-by-line-into-memory-efficiently/6433/4
pub fn readFile(alloc: mem.Allocator, path: []const u8) ![]u8 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();
    return file.readToEndAlloc(alloc, math.maxInt(usize));
}
