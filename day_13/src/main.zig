const std = @import("std");
const Regex = @import("regex").Regex;

const Task = struct {
    ButtonA: [2]f32,
    ButtonB: [2]f32,
    Price: [2]f32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const alloc = arena.allocator();

    const input_file = try std.fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    const input_stat = try input_file.stat();

    const input = try alloc.alloc(u8, input_stat.size);
    _ = try input_file.readAll(input);

    const output = try std.fs.cwd().createFile("output.txt", .{});
    defer output.close();

    _ = try output.write("bytes: []const u");

    var re_button_a = try Regex.compile(alloc, "Button A: X[+-][0-9]+, Y[+-][0-9]+");
    var re_button_b = try Regex.compile(alloc, "Button B: X[+-][0-9]+, Y[+-][0-9]+");
    var re_prize = try Regex.compile(alloc, "Prize: X=[0-9]+, Y=[0-9]+");

    const cap_button_a = try re_button_a.captures(input);
    const cap_button_b = try re_button_b.captures(input);
    const cap_button_prize = try re_prize.captures(input);

    if (cap_button_a) |a| {
        std.debug.print("a: {any}\n", .{a});
    }
    if (cap_button_b) |b| {
        std.debug.print("b: {any}\n", .{b});
    }
    if (cap_button_prize) |prize| {
        std.debug.print("prize: {any}\n", .{prize});
    }

    // cap_button_a
}
