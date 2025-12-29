const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const heap = std.heap;
const GeneralPurposeAllocator = heap.GeneralPurposeAllocator;
const fs = std.fs;
const ArrayList = std.ArrayList;
const math = std.math;
const fmt = std.fmt;

pub fn add(list: ArrayList(u64)) u64 {
    var total: u64 = 0;
    for (list.items) |num| {
        total += num;
    }
    return total;
}

pub fn multiply(list: ArrayList(u64)) u64 {
    var total: u64 = 1;
    for (list.items) |num| {
        total *= num;
    }
    return total;
}

pub fn readFile(alloc: Allocator, path: []const u8) ![]u8 {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();
    return file.readToEndAlloc(alloc, math.maxInt(usize));
}

pub fn sum(alloc: Allocator, input: []u8) !u64 {
    var line_slices = try ArrayList(ArrayList([]const u8)).initCapacity(alloc, 1024);
    defer {
        for (line_slices.items) |*slice| {
            slice.deinit(alloc);
        }
        line_slices.deinit(alloc);
    }

    var lines_iter = mem.splitScalar(u8, input, '\n');

    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;

        var line_slice = try ArrayList([]const u8).initCapacity(alloc, 1024);

        var values = mem.tokenizeScalar(u8, line, ' ');

        while (values.next()) |value| {
            try line_slice.append(alloc, value);
        }

        try line_slices.append(alloc, line_slice);
    }

    var op_slice = line_slices.pop() orelse return error.MissingOps;
    defer op_slice.deinit(alloc);

    var total: u64 = 0;

    for (0..op_slice.items.len) |index| {
        var nums_slice = try ArrayList(u64).initCapacity(alloc, 1024);
        defer nums_slice.deinit(alloc);

        for (line_slices.items) |slice| {
            const value = slice.items[index];
            const num = try fmt.parseInt(u64, value, 10);
            try nums_slice.append(alloc, num);
        }

        const op = op_slice.items[index];

        if (mem.eql(u8, op, "+")) {
            total += add(nums_slice);
        } else if (mem.eql(u8, op, "*")) {
            total += multiply(nums_slice);
        }
    }

    return total;
}

test "test" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const buf = try readFile(alloc, "test.txt");
    defer alloc.free(buf);

    const total = try sum(alloc, buf);

    try std.testing.expectEqual(4277556, total);
}

pub fn main() !void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const buf = try readFile(alloc, "input.txt");
    defer alloc.free(buf);

    const total = try sum(alloc, buf);
    std.debug.print("{d}\n", .{total});
}
