const std = @import("std");
const Regex = @import("regex").Regex;

const Task = struct {
    A: [2]f32,
    B: [2]f32,
    P: [2]f32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const alloc = arena.allocator();

    const output = try std.fs.cwd().createFile("output.txt", .{});
    defer output.close();

    _ = try output.write("bytes: []const u");

    const input_file = try std.fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    const reader = input_file.reader();

    var line = std.ArrayList(u8).init(alloc);
    defer line.deinit();

    const writer = line.writer();

    var items = std.ArrayList(Task).init(alloc);
    defer items.deinit();

    var temp_item = Task{
        .A = undefined,
        .B = undefined,
        .P = undefined,
    };

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();

        var re_button_a = try Regex.compile(alloc, "Button A: X([+-][0-9]+), Y([+-][0-9]+)");
        var re_button_b = try Regex.compile(alloc, "Button B: X([+-][0-9]+), Y([+-][0-9]+)");
        var re_button_prize = try Regex.compile(alloc, "Prize: X=([0-9]+), Y=([0-9]+)");

        const cap_button_a = try re_button_a.captures(line.items);
        const cap_button_b = try re_button_b.captures(line.items);
        const cap_button_prize = try re_button_prize.captures(line.items);

        if (cap_button_a) |a| {
            std.debug.assert(a.len() == 3);
            temp_item.A = .{
                try std.fmt.parseFloat(f32, a.sliceAt(1).?),
                try std.fmt.parseFloat(f32, a.sliceAt(2).?),
            };
        }
        if (cap_button_b) |b| {
            std.debug.assert(b.len() == 3);
            temp_item.B = .{
                try std.fmt.parseFloat(f32, b.sliceAt(1).?),
                try std.fmt.parseFloat(f32, b.sliceAt(2).?),
            };
        }
        if (cap_button_prize) |prize| {
            std.debug.assert(prize.len() == 3);
            temp_item.P = .{
                try std.fmt.parseFloat(f32, prize.sliceAt(1).?),
                try std.fmt.parseFloat(f32, prize.sliceAt(2).?),
            };
            try items.append(temp_item);
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var all_cost: i32 = 0;

    for (items.items) |i| {
        std.debug.print("{any}\n", .{i});
        const an = (i.P[0] * i.B[1] - i.P[1] * i.B[0]) / (i.A[0] * i.B[1] - i.A[1] * i.B[0]);
        const bn = (i.P[0] - i.A[0] * an) / i.B[0];
        std.debug.print("an: {d}\n", .{an});
        std.debug.print("bn: {d}\n", .{bn});

        if (try std.math.mod(f32, an, 1) > 0.0e-10 or try std.math.mod(f32, bn, 1) > 0.0e-10) {
            std.debug.print("No solution!\n", .{});
            continue;
        }

        const cost = 3 * @as(i32, @intFromFloat(an)) + @as(i32, @intFromFloat(bn));
        all_cost += cost;
        std.debug.print("cost: {d}\n", .{cost});
    }

    std.debug.print("All cost: {d}\n", .{all_cost});
}
