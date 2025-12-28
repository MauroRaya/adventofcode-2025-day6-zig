const std: type = @import("std");

const mem: type = std.mem;
const Allocator: type = mem.Allocator;
const SplitIterator = mem.SplitIterator;
const DelimiterType: type = mem.DelimiterType;

const heap: type = std.heap;
const DebugAllocator = heap.DebugAllocator;
const GeneralPurposeAllocator = heap.GeneralPurposeAllocator;

const fs: type = std.fs;
const File: type = fs.File;

const ArrayList = std.ArrayList;
const math: type = std.math;

pub fn add(list: ArrayList(i32)) i32 {
    var total: i32 = 0;
    for (list.items) |num| {
        total += num;
    }
    return total;
}

pub fn multiply(list: ArrayList(i32)) i32 {
    var total: i32 = 1;
    for (list.items) |num| {
        total *= num;
    }
    return total;
}

// https://ziggit.dev/t/how-to-read-an-entire-text-file-line-by-line-into-memory-efficiently/6433/4
pub fn readFile(alloc: Allocator, path: []const u8) ![]u8 {
    const file: File = try fs.cwd().openFile(path, .{});
    defer file.close();
    return file.readToEndAlloc(alloc, math.maxInt(usize));
}

pub fn main() !void {
    var gpa: DebugAllocator(.{}) = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc: Allocator = gpa.allocator();

    const buf: []u8 = try readFile(alloc, "test.txt");
    defer alloc.free(buf);

    var lines: SplitIterator(u8, DelimiterType.scalar) = mem.splitScalar(u8, buf, '\n');

    const LineIterator = mem.TokenIterator(u8, mem.DelimiterType.scalar);
    var lineIts = try ArrayList(LineIterator).initCapacity(alloc, 1024);
    defer lineIts.deinit(alloc);

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const it = mem.tokenizeScalar(u8, line, ' ');
        try lineIts.append(alloc, it);
    }

    var ops = lineIts.pop() orelse return error.MissingOps;

    var total: i32 = 0;

    for (0..4) |_| {
        var nums = try ArrayList(i32).initCapacity(alloc, 1024);
        defer nums.deinit(alloc);

        for (lineIts.items) |*it| {
            if (it.next()) |item| {
                const num = try std.fmt.parseInt(i32, item, 10);
                try nums.append(alloc, num);
            }
        }

        if (ops.next()) |op| {
            if (mem.eql(u8, op, "+")) {
                total += add(nums);
            } else if (mem.eql(u8, op, "*")) {
                total += multiply(nums);
            }
        }
    }

    std.debug.print("{d}\n", .{total});
}
