const std = @import("std");
const gpa = std.heap.c_allocator;
const out = std.io.getStdOut().writer();

const zfetch = @import("zfetch");
const json = @import("json");
const range = @import("range").range;

const u = @import("./../util/index.zig");
const zpm = @import("./../zpm.zig");

//
//

pub fn execute(args: [][]u8) !void {
    const url = try std.mem.join(gpa, "/", &.{ zpm.server_root, "tags" });
    const val = try zpm.server_fetch(url);

    const name_col_width = blk: {
        var w: usize = 0;
        for (val.Array) |tag| {
            const len = tag.get("name").?.String.len;
            if (len > w) {
                w = len;
            }
        }
        break :blk w + 4;
    };

    try out.writeAll("NAME");
    try print_c_n(' ', name_col_width - 4);
    try out.writeAll("DESCRIPTION\n");

    for (val.Array) |tag| {
        const name = tag.get("name").?.String;
        try out.writeAll(name);
        try print_c_n(' ', name_col_width - name.len);
        try out.writeAll(tag.get("description").?.String);
        try out.writeAll("\n");
    }
}

fn print_c_n(c: u8, n: usize) !void {
    for (range(n)) |_, i| {
        try out.writeAll(&.{c});
    }
}
